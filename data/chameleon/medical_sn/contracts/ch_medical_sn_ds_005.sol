// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private owner;

    modifier onlyChiefMedical {
        require(msg.sender==owner);
        _;
    }

    function OpenAccess()
        public
    {
        owner = msg.sender;
    }

    // This function should be protected
    function changeDirector(address _currentSupervisor)
        public
    {
       owner = _currentSupervisor;
    }

    function changeDirectorV2(address _currentSupervisor)
        public
        onlyChiefMedical
    {
       owner = _currentSupervisor;
    }
}