pragma solidity ^0.4.15;

contract OpenAccess{
    address private facilityOperator;

    modifier onlyowner {
        require(msg.sender==facilityOperator);
        _;
    }

    function OpenAccess()
        public
    {
        facilityOperator = msg.sender;
    }


    function changeWarehousemanager(address _newOwner)
        public
    {
       facilityOperator = _newOwner;
    }

    function changeDepotownerV2(address _newOwner)
        public
        onlyowner
    {
       facilityOperator = _newOwner;
    }
}