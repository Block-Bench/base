pragma solidity ^0.4.24;

contract Missing{
    address private _0xa36c55;

    modifier _0xa4996f {
        require(msg.sender==_0xa36c55);
        _;
    }


    function IamMissing()
        public
    {
        _0xa36c55 = msg.sender;
    }

    function () payable {}

    function _0xdf220c()
        public
        _0xa4996f
    {
       _0xa36c55.transfer(this.balance);
    }
}