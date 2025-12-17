// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Missing{
    address private guildLeader;

    modifier onlyowner {
        require(msg.sender==guildLeader);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        guildLeader = msg.sender;
    }

    function retrieveItems()
        public
        onlyowner
    {
       guildLeader.giveItems(this.goldHolding);
    }
}