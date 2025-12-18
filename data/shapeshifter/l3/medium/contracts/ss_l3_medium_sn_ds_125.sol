// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private _0x071ef5;

    modifier _0x15203d {
        require(msg.sender==_0x071ef5);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        _0x071ef5 = msg.sender;
    }

    function () payable {}

    function _0x9f1cb5()
        public
        _0x15203d
    {
       _0x071ef5.transfer(this.balance);
    }
}