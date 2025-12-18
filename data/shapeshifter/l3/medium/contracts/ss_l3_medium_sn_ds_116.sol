// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Missing{
    address private _0x389651;

    modifier _0x8c0318 {
        require(msg.sender==_0x389651);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        _0x389651 = msg.sender;
    }

    function _0x3764ce()
        public
        _0x8c0318
    {
       _0x389651.transfer(this.balance);
    }
}