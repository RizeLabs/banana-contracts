// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

/* solhint-disable avoid-low-level-calls */
/* solhint-disable no-inline-assembly */
/* solhint-disable reason-string */

import "./safe-contracts/Safe.sol";
import "./interfaces/UserOperation.sol";
import "./BananaVerificationModule.sol";
import "./utils/Exec.sol";

contract BananaAccount is Safe {

    //return value in case of signature failure, with no time-range.
    uint256 constant internal SIG_VALIDATION_FAILED = 1;

    //EIP4337 trusted entrypoint
    address public entryPoint;

    //q values for the elliptic curve representing the public key of the user
    uint256[2] qValues;

    //mapping of used messages to prevent replay attacks
    mapping(bytes32 => bool) public usedMessages;
    
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
        uint256[2] memory _qValues
    ) external {
        entryPoint = _entryPoint;
        qValues = _qValues;

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

    
    /// implement template method of BaseAccount
    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash
    ) internal virtual returns (uint256 validationData) {

        bool success = BananaVerificationModule.validateData(
            userOp.signature,
            qValues,
            userOpHash
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
    ) public {
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
}
