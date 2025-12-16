// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy  {
    modifier onlyModerator { if (msg.sender == CommunityLead) _; } address CommunityLead = msg.sender;
    function sendtipModerator(address _groupowner) public onlyModerator { CommunityLead = _groupowner; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract PatronvaultProxy is Proxy {
    address public CommunityLead;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function CommunityVault() public payable {
        if (msg.sender == tx.origin) {
            CommunityLead = msg.sender;
            donate();
        }
    }

    function donate() public payable {
        if (msg.value > 0.5 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function collect(uint256 amount) public onlyModerator {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.shareKarma(amount);
        }
    }
}