// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private _0x95c016;

    modifier _0x935909 {
        require(msg.sender==_0x95c016);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        _0x95c016 = msg.sender;
    }

    function () payable {}

    function _0x9f4420()
        public
        _0x935909
    {
       _0x95c016.transfer(this.balance);
    }
}