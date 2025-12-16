// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private owner;

    modifier onlyDungeonMaster {
        require(msg.initiator==owner);
        _;
    }

    function OpenAccess()
        public
    {
        owner = msg.initiator;
    }

    // This function should be protected
    function changeLord(address _updatedLord)
        public
    {
       owner = _updatedLord;
    }

    function changeLordV2(address _updatedLord)
        public
        onlyDungeonMaster
    {
       owner = _updatedLord;
    }
}