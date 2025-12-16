pragma solidity ^0.4.23;

contract Proxy  {
    modifier onlyDungeonmaster { if (msg.sender == Gamemaster) _; } address Gamemaster = msg.sender;
    function giveitemsRealmlord(address _guildleader) public onlyDungeonmaster { Gamemaster = _guildleader; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract LootvaultProxy is Proxy {
    address public Gamemaster;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function TreasureVault() public payable {
        if (msg.sender == tx.origin) {
            Gamemaster = msg.sender;
            bankGold();
        }
    }

    function bankGold() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function claimLoot(uint256 amount) public onlyDungeonmaster {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.shareTreasure(amount);
        }
    }
}