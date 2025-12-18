pragma solidity ^0.4.15;

contract Missing{
    address private _0xcf51a1;

    modifier _0x22ada2 {
        require(msg.sender==_0xcf51a1);
        _;
    }


    function IamMissing()
        public
    {
        _0xcf51a1 = msg.sender;
    }

    function _0x43cb05()
        public
        _0x22ada2
    {
       _0xcf51a1.transfer(this.balance);
    }
}