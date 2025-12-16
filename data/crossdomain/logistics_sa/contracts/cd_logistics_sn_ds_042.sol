// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionInventoryvault {

    mapping (address => uint) private supplierBalances;

    function shiftStock(address to, uint amount) {
        if (supplierBalances[msg.sender] >= amount) {
            supplierBalances[to] += amount;
            supplierBalances[msg.sender] -= amount;
        }
    }

    function releasegoodsCargocount() public {
        uint amountToCheckoutcargo = supplierBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToCheckoutcargo)("");
        require(success);
        supplierBalances[msg.sender] = 0;
    }
}