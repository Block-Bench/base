// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract WALLET
{
    function Put(uint _0x7ebf8b)
    public
    payable
    {
        var _0x9f391d = Acc[msg.sender];
        _0x9f391d.balance += msg.value;
        _0x9f391d._0xc8664b = _0x7ebf8b>_0xbdce2d?_0x7ebf8b:_0xbdce2d;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xc50d07)
    public
    payable
    {
        var _0x9f391d = Acc[msg.sender];
        if( _0x9f391d.balance>=MinSum && _0x9f391d.balance>=_0xc50d07 && _0xbdce2d>_0x9f391d._0xc8664b)
        {
            if(msg.sender.call.value(_0xc50d07)())
            {
                _0x9f391d.balance-=_0xc50d07;
                LogFile.AddMessage(msg.sender,_0xc50d07,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
    }

    struct Holder
    {
        uint _0xc8664b;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function WALLET(address _0x7557e6) public{
        LogFile = Log(_0x7557e6);
    }
}

contract Log
{
    struct Message
    {
        address Sender;
        string  Data;
        uint Val;
        uint  Time;
    }

    Message[] public History;

    Message LastMsg;

    function AddMessage(address _0xbb36f4,uint _0x9e9826,string _0xbe8066)
    public
    {
        LastMsg.Sender = _0xbb36f4;
        LastMsg.Time = _0xbdce2d;
        LastMsg.Val = _0x9e9826;
        LastMsg.Data = _0xbe8066;
        History.push(LastMsg);
    }
}