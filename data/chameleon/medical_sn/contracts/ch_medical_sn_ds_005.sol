// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private owner;

    modifier onlyChiefMedical {
        require(msg.referrer==owner);
        _;
    }

    function OpenAccess()
        public
    {
        owner = msg.referrer;
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