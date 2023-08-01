// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

/* solhint-disable avoid-low-level-calls */
/* solhint-disable no-inline-assembly */
/* solhint-disable reason-string */

import './safe-contracts/Safe.sol';
import './interfaces/UserOperation.sol';
import './utils/EllipticalCurveLibrary.sol';
import './utils/Exec.sol';
import './utils/BytesUtils.sol';
import './utils/Base64.sol';

contract BananaAccount is Safe {
    using BytesUtils for bytes32;

    //return value in case of signature failure, with no time-range.
    uint256 internal constant SIG_VALIDATION_FAILED = 1;

    //EIP4337 trusted entrypoint
    address public entryPoint;

    //Banana wallet recovery trustedRelayer address
    address public trustedRelayer = 0x563128762c1a881Dc3B5DdbF1B6e1C7f8Ed73C5F;

    //Address corresponding to the recovery private key
    address public recoveryAddress;

    //Cool down period checker
    uint256 public unlockTime;

    // Recovery mode flag
    bool public inRecovery;

    // Updated q values
    uint256[2] nextQValues;

    // Updated encodedIdHash
    bytes32 nextEncodedIdHash;

    modifier notInRecovery {
        require(!inRecovery, "wallet is in recovery mode");
        _;
    }

    modifier onlyInRecovery {
        require(inRecovery, "wallet is not in recovery mode");
        _;
    }

    //maintaing mapping of encodedId to qValues
    mapping (bytes32 => uint256[2]) public encodedIdHashToQValues;

    /// @dev Setup function sets initial storage of contract.
    /// @param _owners List of Safe owners.
    /// @param _threshold Number of required confirmations for a Safe transaction.
    /// @param to Contract address for optional delegate call.
    /// @param data Data payload for optional delegate call.
    /// @param fallbackHandler Handler for fallback calls to this contract
    /// @param paymentToken Token that should be used for the payment (0 is ETH)
    /// @param payment Value that should be paid
    /// @param paymentReceiver Address that should receive the payment (or 0 if tx.origin)
    /// @param _entryPoint Address for the trusted EIP4337 entrypoint
    /// @param _encodedIdHash contains the hash of encodedId which corresponds to the qValues
    /// @param _qValues public address x and y coordinates of the user
    function setupWithEntrypoint(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver,
        address _entryPoint,
        bytes32 _encodedIdHash,
        uint256[2] memory _qValues
    ) external {
        entryPoint = _entryPoint;
        encodedIdHashToQValues[_encodedIdHash] = _qValues;

        _executeAndRevert(
            address(this),
            0,
            abi.encodeCall(
                Safe.setup,
                (
                    _owners,
                    _threshold,
                    to,
                    data,
                    fallbackHandler,
                    paymentToken,
                    payment,
                    paymentReceiver
                )
            ),
            Enum.Operation.DelegateCall
        );
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success, ) = payable(msg.sender).call{
                value: missingAccountFunds,
                gas: type(uint256).max
            }('');
            (success);
            //ignore failure (its EntryPoint's job to verify, not account.)
        }
    }

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256 validationData) {
        _requireFromEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        require(userOp.nonce < type(uint64).max, 'account: nonsequential nonce');
        _payPrefund(missingAccountFunds);
    }

    /**
     * ensure the request comes from the known entrypoint.
     */
    function _requireFromEntryPoint() internal view virtual {
        require(msg.sender == entryPoint, 'account: not from EntryPoint');
    }

    function _getMessageToBeSigned(
        bytes32 userOpHash,
        bytes memory authenticatorData,
        string memory clientDataJSONPre,
        string memory clientDataJSONPost
    ) internal pure returns (bytes32 messageToBeSigned) {
        bytes memory base64RequestId = bytes(Base64.encode(userOpHash.bytes32ToString()));
        string memory clientDataJSON = string.concat(
            clientDataJSONPre,
            string(base64RequestId),
            clientDataJSONPost
        );
        messageToBeSigned = sha256(bytes.concat(authenticatorData, sha256(bytes(clientDataJSON))));
    }

    /// implement template method of BaseAccount
    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash
    ) internal virtual returns (uint256 validationData) {
        (
            uint256 r,
            uint256 s,
            bytes memory authenticatorData,
            string memory clientDataJSONPre,
            string memory clientDataJSONPost,
            bytes32 encodedIdHash
        ) = abi.decode(userOp.signature, (uint256, uint256, bytes, string, string, bytes32));

        bool success = Secp256r1.Verify(
            uint(
                _getMessageToBeSigned(
                    userOpHash,
                    authenticatorData,
                    clientDataJSONPre,
                    clientDataJSONPost
                )
            ),
            [r, s],
            encodedIdHashToQValues[encodedIdHash]
        );

        if (!success) return SIG_VALIDATION_FAILED;
        return 0;
    }

    /// @dev Allows the entrypoint to execute a transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromEntrypoint(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) public notInRecovery {
        // Only Entrypoint is allowed.
        require(msg.sender == entryPoint, 'account: not from EntryPoint');
        // Execute transaction without further confirmations.
        _executeAndRevert(to, value, data, operation);
    }

    /// @dev Allows the entrypoint to execute a batch transactions without any further confirmations.
    /// @param to Destination addresses of transactions.
    /// @param value Ether values of transactions.
    /// @param data Data payloads of transactions.
    /// @param operation Operation types of transactions.
    function execBatchTransactionFromEntrypoint(
        address[] calldata to,
        uint256[] calldata value,
        bytes[] memory data,
        Enum.Operation operation
    ) public notInRecovery {
        // Only Entrypoint is allowed.
        require(msg.sender == entryPoint, 'account: not from EntryPoint');
        // Execute transaction without further confirmations.
        require(to.length == data.length, "wrong array lengths");
        for(uint256 i=0; i < to.length; i++) {
            _executeAndRevert(to[i], value[i], data[i], operation);
        }
    }


    /// @dev check if the signature is valid
    /// @param messageToBeSigned Message to be signed.
    /// @param signature 'r' and 's' values of the signature.
    /// @param publicKey 'x' and 'y' coordinates of the public key of R1 curve
    function verifySignature(bytes32 messageToBeSigned, uint256[2] calldata signature, uint256[2] calldata publicKey) external view returns (bool) {
        return Secp256r1.Verify(
            uint(messageToBeSigned),
            signature,
            publicKey
        );
    }

    function _executeAndRevert(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal {
        bool success = execute(to, value, data, operation, type(uint256).max);

        bytes memory returnData = Exec.getReturnData(type(uint256).max);
        // Revert with the actual reason string
        // Adopted from: https://github.com/Uniswap/v3-periphery/blob/464a8a49611272f7349c970e0fadb7ec1d3c1086/contracts/base/Multicall.sol#L16-L23
        if (!success) {
            if (returnData.length < 68) revert();
            assembly {
                returnData := add(returnData, 0x04)
            }
            revert(abi.decode(returnData, (string)));
        }
    }

    /// @dev There should be only one verified entrypoint per chain
    /// @dev so this function should only be used if there is a problem with
    /// @dev the main entrypoint
    function replaceEntrypoint(address newEntrypoint) public authorized {
        entryPoint = newEntrypoint;
    }

    function addNewDevice(uint256[2] memory _qValues, bytes32 _encodedIdHash) public authorized {
        encodedIdHashToQValues[_encodedIdHash] = _qValues;
    }

    /// @dev Setups the address which can initiate recovery
    /// @dev Can only be called by the account
    /// @param _newRecoveryAddress recovery address generated while recovery setup
    function setupRecovery(address _newRecoveryAddress) external notInRecovery {
        require(msg.sender == address(this), "Only the account can setup recovery");
        require(_newRecoveryAddress != address(0), "recovery address == address(0)");
        recoveryAddress = _newRecoveryAddress;
    }

    /// @dev This function will take in new q values and start a timelock for 48 hours
    /// @param _newQValues new q values to be used for recovery
    function initiateRecovery(uint256[2] memory _newQValues, bytes32 _encodedIdHash, bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) external notInRecovery {
        require(msg.sender == trustedRelayer, "Can only be called via Banana wallet trusted relayer");
        require(_newQValues[0] != 0 && _newQValues[1] != 0, "q values cannot be 0");     
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _message));
        address signer = ecrecover(hash, _v, _r, _s);
        require(signer == recoveryAddress, "Invalid signature");   
        nextQValues = _newQValues;
        nextEncodedIdHash = _encodedIdHash;
        inRecovery = true;
        unlockTime = block.timestamp + 48 hours;
    }

    /// @dev Stops the recovery process by trusted Banana relayer
    /// @dev Can be called directly from trusted relayer on behalf of user for stopping recovery
    /// @dev In a scenario where recovery is initiated from a bad actor
    function stopRecoveryByRelayer(bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) external onlyInRecovery {
        require(msg.sender == trustedRelayer, "Caller should be relayer"); 
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _message));
        address signer = ecrecover(hash, _v, _r, _s);
        require(signer == recoveryAddress, "Invalid signature"); 
        inRecovery = false;
        nextQValues = [0, 0];
        nextEncodedIdHash = 0x0;
        unlockTime = 0;
    }

    /// @dev Stops the recovery process by owner wallet
    /// @dev Can be called directly by the owner in case owner has access to wallet
    /// @dev In a scenario where recovery is initiated from a bad actor and owner has access to wallet
    function stopRecoveryByOwner() external onlyInRecovery {
        require(msg.sender == address(this), "Caller should be smart contract wallet");
        inRecovery = false;
        nextQValues = [0, 0];
        nextEncodedIdHash = 0x0;
        unlockTime = 0;
    }

    /// @dev Updates the q values to the new q values and finalise recovery
    function finaliseRecovery() external onlyInRecovery {
        // don't need this as gelatoe executor would be the only one calling this
        // should we whitelist gelato executor ?
        // require(msg.sender == trustedRelayer, "Only the trusted relayer can finalise recovery");
        require(block.timestamp >= unlockTime - 600, "Account still in recovery");
        encodedIdHashToQValues[nextEncodedIdHash] = nextQValues;
        inRecovery = false;
        nextQValues = [0, 0];
        nextEncodedIdHash = 0x0;
        unlockTime = 0;
    }
}