pragma solidity ^0.4.15;

contract PublicHealthAccess{
    address private owner;

    modifier onlyCustodian {
        require(msg.sender==owner);
        _;
    }

    function PublicHealthAccess()
        public
    {
        owner = msg.sender;
    }


    function transferCustody(address _updatedCustodian)
        public
    {
       owner = _updatedCustodian;
    }

    function changeCustodianV2(address _updatedCustodian)
        public
        onlyCustodian
    {
       owner = _updatedCustodian;
    }
}