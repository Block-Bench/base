pragma solidity ^0.4.18;

contract Test1
{
    address _0xd880c9 = msg.sender;

    function _0xe529d5()
    payable
    public
    {
        require(msg.sender==_0xd880c9);
        _0xd880c9.transfer(this.balance);
    }

    function() payable {}

    function Test()
    payable
    public
    {
        if(msg.value>=1 ether)
        {

            var _0x7c015e = 1;
            var _0x2c82cf = 0;
            var _0x12940d = msg.value*2;

            while(true)
            {
                if(_0x7c015e<_0x2c82cf)break;
                if(_0x7c015e>_0x12940d)break;

                _0x2c82cf=_0x7c015e;
                _0x7c015e++;
            }
            msg.sender.transfer(_0x2c82cf);
        }
    }
}