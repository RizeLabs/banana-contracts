pragma solidity ^0.8.12;

contract Staking {

    uint stakedAmount = 0;
    
    function stake() external payable {
        stakedAmount = stakedAmount + msg.value;
    }

    function returnStake() external {
        payable(0xA8458B544c551Af2ADE164C427a8A4F13A346F2A).transfer(stakedAmount);
    }
}