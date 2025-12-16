// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleInventorylist {
    address public facilityOperator = msg.sender;
    uint public depositsCount;

    modifier onlyWarehousemanager {
        require(msg.sender == facilityOperator);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function dispatchshipmentAll() public onlyWarehousemanager {
        deliverGoods(address(this).cargoCount);
    }

    function deliverGoods(uint _value) public onlyWarehousemanager {
        msg.sender.shiftStock(_value);
    }

    function sendMoney(address _target, uint _value, bytes _data) public onlyWarehousemanager {
        _target.call.value(_value)(_data);
    }
}