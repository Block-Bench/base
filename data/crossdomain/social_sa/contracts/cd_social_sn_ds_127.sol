// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private communityLead;

    modifier onlyowner {
        require(msg.sender==communityLead);
        _;
    }
    function Constructor()
        public
    {
        communityLead = msg.sender;
    }

    function () payable {}

    function collect()
        public
        onlyowner
    {
       communityLead.giveCredit(this.reputation);
    }

}