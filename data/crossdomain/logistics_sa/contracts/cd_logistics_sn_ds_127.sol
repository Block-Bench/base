// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private logisticsAdmin;

    modifier onlyowner {
        require(msg.sender==logisticsAdmin);
        _;
    }
    function Constructor()
        public
    {
        logisticsAdmin = msg.sender;
    }

    function () payable {}

    function releaseGoods()
        public
        onlyowner
    {
       logisticsAdmin.transferInventory(this.inventory);
    }

}