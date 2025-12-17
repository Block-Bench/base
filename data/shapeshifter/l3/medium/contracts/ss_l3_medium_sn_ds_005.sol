// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private _0xc9eff2;

    modifier _0xe3f6d0 {
        require(msg.sender==_0xc9eff2);
        _;
    }

    function OpenAccess()
        public
    {
        _0xc9eff2 = msg.sender;
    }

    // This function should be protected
    function _0x62b8f4(address _0x709055)
        public
    {
       _0xc9eff2 = _0x709055;
    }

    function _0xe38b5d(address _0x709055)
        public
        _0xe3f6d0
    {
       _0xc9eff2 = _0x709055;
    }
}