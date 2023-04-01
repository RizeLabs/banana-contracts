pragma solidity ^0.8.12;

interface IBananaAccount {
    function setupRecovery(address _newRecoveryAddress) external;
    function initiateRecovery(uint256[2] memory _newQValues, bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) external;
    function stopRecoveryByRelayer(bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) external;
    function finaliseRecovery() external;
}

contract BananaRelayer {

    uint256 public lastScheduledCallTime;
    mapping(uint256 => address[]) public scheduledCalls;

    function initiateRecovery(address _account, uint256[2] memory _newQValues, bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) external {
        // when it is first scheduled call we will update last scheduled call time
        if(lastScheduledCallTime == 0) {
            lastScheduledCallTime = block.timestamp;
            scheduledCalls[lastScheduledCallTime].push(_account);
        }
        // in case if time difference between last scheduled call and current time is less than 10 minutes we will batch the calls
        else if(block.timestamp - lastScheduledCallTime <= 600) {
            scheduledCalls[lastScheduledCallTime].push(_account);
        // else will create another batch and updated last schedule time
        } else {
            lastScheduledCallTime = block.timestamp;
            scheduledCalls[lastScheduledCallTime].push(_account);
        }
        IBananaAccount(_account).initiateRecovery(_newQValues, _message, _v, _r, _s);
    }

    function stopRecoveryByRelayer(address _account, bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) external {
        IBananaAccount(_account).stopRecoveryByRelayer(_message, _v, _r, _s);
    }

    function checker()
        external
        view
        returns (bool canExec, bytes memory execPayload)
    {
        uint256 addressesLength = scheduledCalls[block.timestamp].length;

        if(addressesLength == 0) {
            return (false, "");
        }

        for (uint256 i = 0; i < addressesLength; i++) {
            address currentAddress = scheduledCalls[block.timestamp][i];
            return (true, abi.encodeCall(IBananaAccount(currentAddress).finaliseRecovery, ()))
        }
    }
}