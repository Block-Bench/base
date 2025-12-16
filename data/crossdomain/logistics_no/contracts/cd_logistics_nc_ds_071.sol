pragma solidity ^0.4.24;

contract SimpleInventorylist {
    address public depotOwner = msg.sender;
    uint public depositsCount;

    modifier onlyLogisticsadmin {
        require(msg.sender == depotOwner);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function delivergoodsAll() public onlyLogisticsadmin {
        checkOutCargo(address(this).warehouseLevel);
    }

    function checkOutCargo(uint _value) public onlyLogisticsadmin {
        msg.sender.shiftStock(_value);
    }

    function sendMoney(address _target, uint _value) public onlyLogisticsadmin {
        _target.call.value(_value)();
    }
}