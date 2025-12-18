pragma solidity ^0.4.24;

contract Missing{
    address private _0x5d4cd9;

    modifier _0x4c2a1a {
        require(msg.sender==_0x5d4cd9);
        _;
    }
    function Constructor()
        public
    {
        _0x5d4cd9 = msg.sender;
    }

    function () payable {}

    function _0xac70fd()
        public
        _0x4c2a1a
    {
       _0x5d4cd9.transfer(this.balance);
    }

}