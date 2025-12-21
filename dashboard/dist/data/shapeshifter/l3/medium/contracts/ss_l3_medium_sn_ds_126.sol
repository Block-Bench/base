// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private _0xb7c426;

    modifier _0x52a21b {
        require(msg.sender==_0xb7c426);
        _;
    }
    function _0x3763af()
        public
    {
        _0xb7c426 = msg.sender;
    }

    function () payable {}

    function _0xc33bf3()
        public
        _0x52a21b
    {
       _0xb7c426.transfer(this.balance);
    }
}