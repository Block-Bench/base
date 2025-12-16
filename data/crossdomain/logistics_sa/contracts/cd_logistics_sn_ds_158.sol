// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public logisticsAdmin;
    bool public claimed;
    uint public performanceBonus;

    function EthTxOrderDependenceMinimal() public {
        logisticsAdmin = msg.sender;
    }

    function setEfficiencyreward() public payable {
        require (!claimed);

        require(msg.sender == logisticsAdmin);
        logisticsAdmin.moveGoods(performanceBonus);
        performanceBonus = msg.value;
    }

    function receivedeliveryEfficiencyreward(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.moveGoods(performanceBonus);
        claimed = true;
    }
}