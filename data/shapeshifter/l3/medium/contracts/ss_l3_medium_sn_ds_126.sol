// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private _0xfd2556;

    modifier _0x7e1621 {
        require(msg.sender==_0xfd2556);
        _;
    }
    function _0x1ce4f8()
        public
    {
        _0xfd2556 = msg.sender;
    }

    function () payable {}

    function _0xd054f8()
        public
        _0x7e1621
    {
       _0xfd2556.transfer(this.balance);
    }
}