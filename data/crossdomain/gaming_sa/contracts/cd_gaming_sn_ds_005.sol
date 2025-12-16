// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private guildLeader;

    modifier onlyowner {
        require(msg.sender==guildLeader);
        _;
    }

    function OpenAccess()
        public
    {
        guildLeader = msg.sender;
    }

    // This function should be protected
    function changeRealmlord(address _newOwner)
        public
    {
       guildLeader = _newOwner;
    }

    function changeDungeonmasterV2(address _newOwner)
        public
        onlyowner
    {
       guildLeader = _newOwner;
    }
}