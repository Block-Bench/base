// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract OpenAccess{
    address private logisticsAdmin;

    modifier onlyowner {
        require(msg.sender==logisticsAdmin);
        _;
    }

    function OpenAccess()
        public
    {
        logisticsAdmin = msg.sender;
    }

    // This function should be protected
    function changeDepotowner(address _newOwner)
        public
    {
       logisticsAdmin = _newOwner;
    }

    function changeFacilityoperatorV2(address _newOwner)
        public
        onlyowner
    {
       logisticsAdmin = _newOwner;
    }
}