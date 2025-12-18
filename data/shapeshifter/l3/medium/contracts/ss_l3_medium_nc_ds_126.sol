pragma solidity ^0.4.24;

contract Missing{
    address private _0x804a98;

    modifier _0x029dc9 {
        require(msg.sender==_0x804a98);
        _;
    }
    function _0xa8e1da()
        public
    {
        _0x804a98 = msg.sender;
    }

    function () payable {}

    function _0xe69b79()
        public
        _0x029dc9
    {
       _0x804a98.transfer(this.balance);
    }
}