// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleShipmentrecord {
    address public logisticsAdmin = msg.sender;
    uint public depositsCount;

    modifier onlyWarehousemanager {
        require(msg.sender == logisticsAdmin);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function delivergoodsAll() public onlyWarehousemanager {
        releaseGoods(address(this).goodsOnHand);
    }

    function releaseGoods(uint _value) public onlyWarehousemanager {
        msg.sender.moveGoods(_value);
    }

    function sendMoney(address _target, uint _value) public onlyWarehousemanager {
        _target.call.value(_value)();
    }
}