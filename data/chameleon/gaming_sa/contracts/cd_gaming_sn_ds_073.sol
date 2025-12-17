// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Proxy  {
    modifier onlyRealmlord { if (msg.sender == GuildLeader) _; } address GuildLeader = msg.sender;
    function giveitemsRealmlord(address _realmlord) public onlyRealmlord { GuildLeader = _realmlord; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract TreasurevaultProxy is Proxy {
    address public GuildLeader;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function TreasureVault() public payable {
        if (msg.sender == tx.origin) {
            GuildLeader = msg.sender;
            stashItems();
        }
    }

    function stashItems() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function takePrize(uint256 amount) public onlyRealmlord {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.giveItems(amount);
        }
    }
}