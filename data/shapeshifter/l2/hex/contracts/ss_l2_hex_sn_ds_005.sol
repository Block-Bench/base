// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private _0x7fcd4b;

    modifier _0x01f0ce {
        require(msg.sender==_0x7fcd4b);
        _;
    }

    function OpenAccess()
        public
    {
        _0x7fcd4b = msg.sender;
    }

    // This function should be protected
    function _0x0d7fd6(address _0x05acb2)
        public
    {
       _0x7fcd4b = _0x05acb2;
    }

    function _0xe2ab04(address _0x05acb2)
        public
        _0x01f0ce
    {
       _0x7fcd4b = _0x05acb2;
    }
}