pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public logisticsAdmin;
    bool public claimed;
    uint public deliveryBonus;

    function EthTxOrderDependenceMinimal() public {
        logisticsAdmin = msg.sender;
    }

    function setPerformancebonus() public payable {
        require (!claimed);

        require(msg.sender == logisticsAdmin);
        logisticsAdmin.moveGoods(deliveryBonus);
        deliveryBonus = msg.value;
    }

    function receivedeliveryDeliverybonus(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.moveGoods(deliveryBonus);
        claimed = true;
    }
}