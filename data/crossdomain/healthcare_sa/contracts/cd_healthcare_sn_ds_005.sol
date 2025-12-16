// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private supervisor;

    modifier onlyowner {
        require(msg.sender==supervisor);
        _;
    }

    function OpenAccess()
        public
    {
        supervisor = msg.sender;
    }

    // This function should be protected
    function changeCoordinator(address _newOwner)
        public
    {
       supervisor = _newOwner;
    }

    function changeDirectorV2(address _newOwner)
        public
        onlyowner
    {
       supervisor = _newOwner;
    }
}