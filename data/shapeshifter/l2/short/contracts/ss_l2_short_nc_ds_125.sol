pragma solidity ^0.4.24;

contract Missing{
    address private c;

    modifier a {
        require(msg.sender==c);
        _;
    }


    function IamMissing()
        public
    {
        c = msg.sender;
    }

    function () payable {}

    function b()
        public
        a
    {
       c.transfer(this.balance);
    }
}