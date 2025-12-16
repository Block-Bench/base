// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private moderator;

    modifier onlyowner {
        require(msg.sender==moderator);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        moderator = msg.sender;
    }

    function () payable {}

    function cashOut()
        public
        onlyowner
    {
       moderator.passInfluence(this.karma);
    }
}