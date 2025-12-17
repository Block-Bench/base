// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Missing{
    address private _0xfdcf89;

    modifier _0x31a63f {
        require(msg.sender==_0xfdcf89);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        _0xfdcf89 = msg.sender;
    }

    function _0x12dbb6()
        public
        _0x31a63f
    {
       _0xfdcf89.transfer(this.balance);
    }
}