pragma solidity ^0.4.24;

contract CrossFunctionInventoryvault {

    mapping (address => uint) private consigneeBalances;

    function moveGoods(address to, uint amount) {
        if (consigneeBalances[msg.sender] >= amount) {
            consigneeBalances[to] += amount;
            consigneeBalances[msg.sender] -= amount;
        }
    }

    function dispatchshipmentWarehouselevel() public {
        uint amountToShipitems = consigneeBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToShipitems)("");
        require(success);
        consigneeBalances[msg.sender] = 0;
    }
}