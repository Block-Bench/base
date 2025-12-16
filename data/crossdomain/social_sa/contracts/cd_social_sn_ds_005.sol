// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private communityLead;

    modifier onlyowner {
        require(msg.sender==communityLead);
        _;
    }

    function OpenAccess()
        public
    {
        communityLead = msg.sender;
    }

    // This function should be protected
    function changeFounder(address _newOwner)
        public
    {
       communityLead = _newOwner;
    }

    function changeAdminV2(address _newOwner)
        public
        onlyowner
    {
       communityLead = _newOwner;
    }
}