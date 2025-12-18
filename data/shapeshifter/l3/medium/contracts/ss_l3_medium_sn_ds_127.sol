// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private _0x7253aa;

    modifier _0x7cb6fd {
        require(msg.sender==_0x7253aa);
        _;
    }
    function Constructor()
        public
    {
        _0x7253aa = msg.sender;
    }

    function () payable {}

    function _0x4d3196()
        public
        _0x7cb6fd
    {
       _0x7253aa.transfer(this.balance);
    }

}