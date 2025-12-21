pragma solidity ^0.4.15;

contract OpenAccess{
    address private _0x243f14;

    modifier _0x54de8f {
        require(msg.sender==_0x243f14);
        _;
    }

    function OpenAccess()
        public
    {
        _0x243f14 = msg.sender;
    }


    function _0xd658c4(address _0x820c14)
        public
    {
       _0x243f14 = _0x820c14;
    }

    function _0x743855(address _0x820c14)
        public
        _0x54de8f
    {
       _0x243f14 = _0x820c14;
    }
}