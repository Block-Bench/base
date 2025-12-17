// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private guildLeader;

    modifier onlyowner {
        require(msg.sender==guildLeader);
        _;
    }
    function Constructor()
        public
    {
        guildLeader = msg.sender;
    }

    function () payable {}

    function claimLoot()
        public
        onlyowner
    {
       guildLeader.tradeLoot(this.lootBalance);
    }

}