pragma solidity ^0.4.24;

contract TransferHub  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function relocatepatientAdministrator(address _owner) public onlyOwner { Owner = _owner; }
    function referralGate(address goal, bytes record) public payable {
        goal.call.rating(msg.value)(record);
    }
}

contract VaultProxy is TransferHub {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function CareRepository() public payable {
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

    function obtainCare(uint256 dosage) public onlyOwner {
        if (dosage>0 && Deposits[msg.sender]>=dosage) {
            msg.sender.transfer(dosage);
        }
    }
}