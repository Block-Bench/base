// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Missing{
    address private _0x58afd5;

    modifier _0x18c6ca {
        require(msg.sender==_0x58afd5);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        _0x58afd5 = msg.sender;
    }

    function _0xd585d6()
        public
        _0x18c6ca
    {
       _0x58afd5.transfer(this.balance);
    }
}