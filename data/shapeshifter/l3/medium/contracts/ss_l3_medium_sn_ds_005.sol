// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private _0xc9a836;

    modifier _0xc197dd {
        require(msg.sender==_0xc9a836);
        _;
    }

    function OpenAccess()
        public
    {
        _0xc9a836 = msg.sender;
    }

    // This function should be protected
    function _0x9a4f09(address _0x02b965)
        public
    {
       _0xc9a836 = _0x02b965;
    }

    function _0xbc766e(address _0x02b965)
        public
        _0xc197dd
    {
       _0xc9a836 = _0x02b965;
    }
}