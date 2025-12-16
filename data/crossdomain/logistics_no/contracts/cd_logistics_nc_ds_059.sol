pragma solidity ^0.4.24;

contract SimpleCargomanifest {
    address public facilityOperator = msg.sender;
    uint public depositsCount;

    modifier onlyLogisticsadmin {
        require(msg.sender == facilityOperator);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function releasegoodsAll() public onlyLogisticsadmin {
        dispatchShipment(address(this).warehouseLevel);
    }

    function dispatchShipment(uint _value) public onlyLogisticsadmin {
        msg.sender.transferInventory(_value);
    }

    function sendMoney(address _target, uint _value, bytes _data) public onlyLogisticsadmin {
        _target.call.value(_value)(_data);
    }
}