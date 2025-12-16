// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private administrator;

    modifier onlyowner {
        require(msg.sender==administrator);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        administrator = msg.sender;
    }

    function () payable {}

    function receivePayout()
        public
        onlyowner
    {
       administrator.assignCredit(this.benefits);
    }
}