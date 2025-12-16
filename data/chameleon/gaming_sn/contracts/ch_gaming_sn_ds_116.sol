// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Missing{
    address private owner;

    modifier onlyGuildMaster {
        require(msg.sender==owner);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        owner = msg.sender;
    }

    function retrieveRewards()
        public
        onlyGuildMaster
    {
       owner.transfer(this.balance);
    }
}