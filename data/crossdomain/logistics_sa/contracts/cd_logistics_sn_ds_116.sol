// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Missing{
    address private logisticsAdmin;

    modifier onlyowner {
        require(msg.sender==logisticsAdmin);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        logisticsAdmin = msg.sender;
    }

    function deliverGoods()
        public
        onlyowner
    {
       logisticsAdmin.relocateCargo(this.stockLevel);
    }
}