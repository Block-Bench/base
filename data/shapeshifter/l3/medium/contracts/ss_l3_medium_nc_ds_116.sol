pragma solidity ^0.4.15;

contract Missing{
    address private _0x6ad72c;

    modifier _0x81e59b {
        require(msg.sender==_0x6ad72c);
        _;
    }


    function IamMissing()
        public
    {
        _0x6ad72c = msg.sender;
    }

    function _0x2cdc19()
        public
        _0x81e59b
    {
       _0x6ad72c.transfer(this.balance);
    }
}