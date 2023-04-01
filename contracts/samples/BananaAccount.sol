// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

/* solhint-disable avoid-low-level-calls */
/* solhint-disable no-inline-assembly */
/* solhint-disable reason-string */

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


import "../safe-contracts/Safe.sol";
import "../interfaces/UserOperation.sol";
import "./EllipticCurve.sol";
import "../utils/Exec.sol";
import './Base64.sol';

contract BananaAccount is Safe {
    using ECDSA for bytes32;

    //return value in case of signature failure, with no time-range.
    uint256 constant internal SIG_VALIDATION_FAILED = 1;

    //elliptic curve used for the signature verification
    address ellipticCurve;

    //EIP4337 trusted entrypoint
    address public entryPoint;

    //Banana wallet recovery trustedRelayer address
    address public trustedRelayer = 0x605D0Cb492423De25C690aA316a9da4Af935Bcc4;

    //q values for the elliptic curve representing the public key of the user
    uint256[2] qValues;

    address public recoveryAddress;

    uint256 public unlockTime;

    bool public inRecovery;

    uint256[2] nextQValues;

     modifier notInRecovery {
        require(!inRecovery, "wallet is in recovery mode");
        _;
    }

    modifier onlyInRecovery {
        require(inRecovery, "wallet is not in recovery mode");
        _;
    }
    
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
        uint256[2] memory _qValues,
        address _ellipticCurve
    ) external {
        entryPoint = _entryPoint;
        qValues = _qValues;
        ellipticCurve = _ellipticCurve;

        _executeAndRevert(
            address(this),
            0,
            abi.encodeCall(Safe.setup, (
                _owners, _threshold,
                to, data,
                fallbackHandler,paymentToken,
                payment, paymentReceiver
            )),
            Enum.Operation.DelegateCall
        );
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value : missingAccountFunds, gas : type(uint256).max}("");
            (success);
            //ignore failure (its EntryPoint's job to verify, not account.)
        }
    }

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
    external  returns (uint256 validationData) {
        _requireFromEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        if (userOp.initCode.length == 0) {
            _validateAndUpdateNonce(userOp);
        }
        _payPrefund(missingAccountFunds);
    }

    /**
    * ensure the request comes from the known entrypoint.
    */
    function _requireFromEntryPoint() internal virtual view {
        require(msg.sender == entryPoint, "account: not from EntryPoint");
    }

    /// implement template method of BaseAccount
    function _validateAndUpdateNonce(
        UserOperation calldata userOp
    ) internal {
        require(nonce++ == userOp.nonce, "account: invalid nonce");
    }

    function _getRSValues(bytes calldata signature)
        external
        pure
        returns (uint256 r, uint256 s)
    {
        r = uint256(bytes32(signature[0:32]));
        s = uint256(bytes32(signature[32:64]));
    }

    function _getRequestId(bytes calldata clientDataJSON)
        external
        pure
        returns (bytes memory requestIdFromClientDataJSON)
    {
        return clientDataJSON[40:];
    }

    function concatBytes(bytes memory a, bytes memory b)
        public
        pure
        returns (bytes memory)
    {
        bytes memory result = new bytes(a.length + b.length);
        uint256 i;
        uint256 j;

        for (i = 0; i < a.length; i++) {
            result[j++] = a[i];
        }
        for (i = 0; i < b.length; i++) {
            result[j++] = b[i];
        }
        return result;
    }

    function toHex16(bytes16 data) internal pure returns (bytes32 result) {
        result =
            (bytes32(data) &
                0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000) |
            ((bytes32(data) &
                0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >>
                64);
        result =
            (result &
                0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000) |
            ((result &
                0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >>
                32);
        result =
            (result &
                0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000) |
            ((result &
                0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >>
                16);
        result =
            (result &
                0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000) |
            ((result &
                0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >>
                8);
        result =
            ((result &
                0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >>
                4) |
            ((result &
                0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >>
                8);
        result = bytes32(
            0x3030303030303030303030303030303030303030303030303030303030303030 +
                uint256(result) +
                (((uint256(result) +
                    0x0606060606060606060606060606060606060606060606060606060606060606) >>
                    4) &
                    0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) *
                7
        );
    }

    function toHex(bytes32 data) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '0x',
                    toHex16(bytes16(data)),
                    toHex16(bytes16(data << 128))
                )
            );
    }

    function lower(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint256 i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    function _lower(bytes1 _b1) private pure returns (bytes1) {
        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }

        return _b1;
    }

    function getRequestIdFromClientDataJSON(bytes calldata clientDataJSON)
        public
        pure
        returns (bytes calldata)
    {
        return clientDataJSON[36:124];
    }

    function compareBytes(bytes memory b1, bytes memory b2)
        public
        pure
        returns (bool)
    {
        if (b1.length != b2.length) {
            return false;
        }
        for (uint256 i = 0; i < b1.length; i++) {
            if (b1[i] != b2[i]) {
                return false;
            }
        }
        return true;
    }

    /// implement template method of BaseAccount
    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash
    ) internal virtual returns (uint256 validationData) {

         (uint r, uint s, bytes32 message, bytes32 clientDataJsonHash) = abi.decode(
            userOp.signature,
            (uint, uint, bytes32, bytes32)
        );

        string memory userOpHashHex = lower(toHex(userOpHash));

        bytes memory base64RequestId = bytes(Base64.encode(userOpHashHex));

        require(keccak256(base64RequestId) == clientDataJsonHash, "Signed userOp doesn't match");

        bool success = EllipticCurve(ellipticCurve).validateSignature(
            message,
            [r, s],
            qValues
        );
        // bytes32 hash = userOpHash.toEthSignedMessageHash();
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
        require(msg.sender == entryPoint, "account: not from EntryPoint");
        // Execute transaction without further confirmations.
        _executeAndRevert(to, value, data, operation);
    }

    function _executeAndRevert(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal {

        bool success = execute(
            to,
            value,
            data,
            operation,
            type(uint256).max
        );

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
    function initiateRecovery(uint256[2] memory _newQValues, bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) external notInRecovery {
        require(msg.sender == trustedRelayer, "Can only be called via Banana wallet trusted relayer");
        require(_newQValues[0] != 0 && _newQValues[1] != 0, "q values cannot be 0");     
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _message));
        address signer = ecrecover(hash, _v, _r, _s);
        require(signer == recoveryAddress, "Invalid signature");   
        nextQValues = _newQValues;
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
        unlockTime = 0;
    }

    /// @dev Stops the recovery process by owner wallet
    /// @dev Can be called directly by the owner in case owner has access to wallet
    /// @dev In a scenario where recovery is initiated from a bad actor and owner has access to wallet
    function stopRecoveryByOwner() external onlyInRecovery {
        require(msg.sender == address(this), "Caller should be smart contract wallet");
        inRecovery = false;
        nextQValues = [0, 0];
        unlockTime = 0;
    }

    /// @dev Updates the q values to the new q values and finalise recovery
    function finaliseRecovery() external onlyInRecovery {
        // don't need this as gelatoe executor would be the only one calling this
        // should we whitelist gelato executor ?
        // require(msg.sender == trustedRelayer, "Only the trusted relayer can finalise recovery");
        require(block.timestamp >= unlockTime - 600, "Account still in recovery");
        qValues = nextQValues;
        inRecovery = false;
        nextQValues = [0, 0];
        unlockTime = 0;
    }
}
