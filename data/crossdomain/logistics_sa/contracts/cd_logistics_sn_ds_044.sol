// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleWarehouse {

    mapping (address => uint) private vendorBalances;

    function releasegoodsInventory() public {
        uint amountToReleasegoods = vendorBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToReleasegoods)("");
        require(success);
        vendorBalances[msg.sender] = 0;
    }
}