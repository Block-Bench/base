pragma solidity ^0.4.15;

contract OpenAccess{
    address private _0x15e1cf;

    modifier _0x15bf41 {
        require(msg.sender==_0x15e1cf);
        _;
    }

    function OpenAccess()
        public
    {
        _0x15e1cf = msg.sender;
    }


    function _0x6be18e(address _0x6b04fe)
        public
    {
       _0x15e1cf = _0x6b04fe;
    }

    function _0x9e5a7c(address _0x6b04fe)
        public
        _0x15bf41
    {
       _0x15e1cf = _0x6b04fe;
    }
}