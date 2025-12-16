// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }

    function OpenAccess()
        public
    {
        _executeOpenAccessLogic(msg.sender);
    }

    function _executeOpenAccessLogic(address _sender) internal {
        owner = _sender;
    }

    // This function should be protected
    function changeOwner(address _newOwner)
        public
    {
       owner = _newOwner;
    }

    function changeOwnerV2(address _newOwner)
        public
        onlyowner
    {
       owner = _newOwner;
    }
}