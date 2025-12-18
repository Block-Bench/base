pragma solidity ^0.4.24;

contract Missing{
    address private _0x4ee3f4;

    modifier _0x0693b9 {
        require(msg.sender==_0x4ee3f4);
        _;
    }
    function Constructor()
        public
    {
        _0x4ee3f4 = msg.sender;
    }

    function () payable {}

    function _0xf6f819()
        public
        _0x0693b9
    {
       _0x4ee3f4.transfer(this.balance);
    }

}