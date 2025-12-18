pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyCustodian {
        require(msg.sender==owner);
        _;
    }
    function missing()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function dischargeFunds()
        public
        onlyCustodian
    {
       owner.transfer(this.balance);
    }
}