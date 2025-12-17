// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private _0x9b73d0;

    modifier _0x5b8a2a {
        require(msg.sender==_0x9b73d0);
        _;
    }
    function _0x0a83e0()
        public
    {
        _0x9b73d0 = msg.sender;
    }

    function () payable {}

    function _0xd6cb98()
        public
        _0x5b8a2a
    {
       _0x9b73d0.transfer(this.balance);
    }
}