// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private _0x526da5;

    modifier _0xa77ddf {
        require(msg.sender==_0x526da5);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        _0x526da5 = msg.sender;
    }

    function () payable {}

    function _0xadbe0e()
        public
        _0xa77ddf
    {
       _0x526da5.transfer(this.balance);
    }
}