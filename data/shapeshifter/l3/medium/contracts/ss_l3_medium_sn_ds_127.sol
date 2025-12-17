// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private _0x97a9f7;

    modifier _0x682e7f {
        require(msg.sender==_0x97a9f7);
        _;
    }
    function Constructor()
        public
    {
        _0x97a9f7 = msg.sender;
    }

    function () payable {}

    function _0x12ca8d()
        public
        _0x682e7f
    {
       _0x97a9f7.transfer(this.balance);
    }

}