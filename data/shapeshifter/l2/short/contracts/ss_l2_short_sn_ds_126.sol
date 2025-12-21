// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private d;

    modifier a {
        require(msg.sender==d);
        _;
    }
    function c()
        public
    {
        d = msg.sender;
    }

    function () payable {}

    function b()
        public
        a
    {
       d.transfer(this.balance);
    }
}