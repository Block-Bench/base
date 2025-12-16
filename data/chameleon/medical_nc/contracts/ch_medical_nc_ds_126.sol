pragma solidity ^0.4.24;

contract Missing{
    address private owner;

    modifier onlyDirector {
        require(msg.sender==owner);
        _;
    }
    function missing()
        public
    {
        owner = msg.sender;
    }

    function () payable {}

    function dispenseMedication()
        public
        onlyDirector
    {
       owner.transfer(this.balance);
    }
}