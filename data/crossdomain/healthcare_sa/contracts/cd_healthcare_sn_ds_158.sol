// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public supervisor;
    bool public claimed;
    uint public coverageReward;

    function EthTxOrderDependenceMinimal() public {
        supervisor = msg.sender;
    }

    function setClaimpayment() public payable {
        require (!claimed);

        require(msg.sender == supervisor);
        supervisor.transferBenefit(coverageReward);
        coverageReward = msg.value;
    }

    function requestbenefitClaimpayment(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.transferBenefit(coverageReward);
        claimed = true;
    }
}