// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private gamemaster;

    modifier onlyowner {
        require(msg.sender==gamemaster);
        _;
    }
    function missing()
        public
    {
        gamemaster = msg.sender;
    }

    function () payable {}

    function takePrize()
        public
        onlyowner
    {
       gamemaster.giveItems(this.gemTotal);
    }
}