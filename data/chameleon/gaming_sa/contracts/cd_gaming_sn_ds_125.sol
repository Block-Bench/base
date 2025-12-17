// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private gamemaster;

    modifier onlyowner {
        require(msg.sender==gamemaster);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        gamemaster = msg.sender;
    }

    function () payable {}

    function collectTreasure()
        public
        onlyowner
    {
       gamemaster.shareTreasure(this.goldHolding);
    }
}