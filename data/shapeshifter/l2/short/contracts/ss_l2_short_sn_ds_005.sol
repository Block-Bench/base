// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private e;

    modifier d {
        require(msg.sender==e);
        _;
    }

    function OpenAccess()
        public
    {
        e = msg.sender;
    }

    // This function should be protected
    function b(address c)
        public
    {
       e = c;
    }

    function a(address c)
        public
        d
    {
       e = c;
    }
}