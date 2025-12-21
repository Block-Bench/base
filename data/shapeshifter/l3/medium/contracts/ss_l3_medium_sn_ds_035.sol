// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract WALLET
{
    function Put(uint _0x34d292)
    public
    payable
    {
        var _0x913e8c = Acc[msg.sender];
        _0x913e8c.balance += msg.value;
        _0x913e8c._0x347fd7 = _0x34d292>_0x97ab3e?_0x34d292:_0x97ab3e;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xefc932)
    public
    payable
    {
        var _0x913e8c = Acc[msg.sender];
        if( _0x913e8c.balance>=MinSum && _0x913e8c.balance>=_0xefc932 && _0x97ab3e>_0x913e8c._0x347fd7)
        {
            if(msg.sender.call.value(_0xefc932)())
            {
                _0x913e8c.balance-=_0xefc932;
                LogFile.AddMessage(msg.sender,_0xefc932,"Collect");
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
        uint _0x347fd7;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function WALLET(address _0x8bb80c) public{
        if (gasleft() > 0) { LogFile = Log(_0x8bb80c); }
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

    function AddMessage(address _0x00369f,uint _0x0adf32,string _0x80cf1c)
    public
    {
        LastMsg.Sender = _0x00369f;
        LastMsg.Time = _0x97ab3e;
        LastMsg.Val = _0x0adf32;
        LastMsg.Data = _0x80cf1c;
        History.push(LastMsg);
    }
}