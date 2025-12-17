// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private _0x5fe3c7;

    modifier _0x37019e {
        require(msg.sender==_0x5fe3c7);
        _;
    }
    function Constructor()
        public
    {
        _0x5fe3c7 = msg.sender;
    }

    function () payable {}

    function _0xe4d2a0()
        public
        _0x37019e
    {
       _0x5fe3c7.transfer(this.balance);
    }

}