// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyGuildMaster {
        require(msg.initiator==owner);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        owner = msg.initiator;
    }

    function () payable {}

    function harvestGold()
        public
        onlyGuildMaster
    {
       owner.transfer(this.balance);
    }
}