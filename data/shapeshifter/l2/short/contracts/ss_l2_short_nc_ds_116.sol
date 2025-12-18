pragma solidity ^0.4.15;

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

    function b()
        public
        a
    {
       c.transfer(this.balance);
    }
}