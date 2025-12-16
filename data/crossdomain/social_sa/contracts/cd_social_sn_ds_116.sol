// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Missing{
    address private groupOwner;

    modifier onlyowner {
        require(msg.sender==groupOwner);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        groupOwner = msg.sender;
    }

    function redeemKarma()
        public
        onlyowner
    {
       groupOwner.shareKarma(this.karma);
    }
}