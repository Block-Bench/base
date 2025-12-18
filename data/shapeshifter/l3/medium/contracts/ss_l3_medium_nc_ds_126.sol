pragma solidity ^0.4.24;

contract Missing{
    address private _0xbdb3e7;

    modifier _0x42019d {
        require(msg.sender==_0xbdb3e7);
        _;
    }
    function _0x11e855()
        public
    {
        _0xbdb3e7 = msg.sender;
    }

    function () payable {}

    function _0xa66312()
        public
        _0x42019d
    {
       _0xbdb3e7.transfer(this.balance);
    }
}