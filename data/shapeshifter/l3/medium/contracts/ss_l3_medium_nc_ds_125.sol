pragma solidity ^0.4.24;

contract Missing{
    address private _0xef8c04;

    modifier _0xc73934 {
        require(msg.sender==_0xef8c04);
        _;
    }


    function IamMissing()
        public
    {
        _0xef8c04 = msg.sender;
    }

    function () payable {}

    function _0x8a5763()
        public
        _0xc73934
    {
       _0xef8c04.transfer(this.balance);
    }
}