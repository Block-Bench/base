pragma solidity ^0.5.0;

contract SimpleInventoryvault {

    mapping (address => uint) private consigneeBalances;

    function dispatchshipmentInventory() public {
        uint amountToCheckoutcargo = consigneeBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToCheckoutcargo)("");
        require(success);
        consigneeBalances[msg.sender] = 0;
    }
}