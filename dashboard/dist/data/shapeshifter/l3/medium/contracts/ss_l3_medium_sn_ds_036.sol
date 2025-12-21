// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _0x5bcba9)
    public
    payable
    {
        var _0xb47e9b = Acc[msg.sender];
        _0xb47e9b.balance += msg.value;
        _0xb47e9b._0x7cf707 = _0x5bcba9>_0x8c98ab?_0x5bcba9:_0x8c98ab;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xbffe29)
    public
    payable
    {
        var _0xb47e9b = Acc[msg.sender];
        if( _0xb47e9b.balance>=MinSum && _0xb47e9b.balance>=_0xbffe29 && _0x8c98ab>_0xb47e9b._0x7cf707)
        {
            if(msg.sender.call.value(_0xbffe29)())
            {
                _0xb47e9b.balance-=_0xbffe29;
                LogFile.AddMessage(msg.sender,_0xbffe29,"Collect");
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
        uint _0x7cf707;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function MY_BANK(address _0x8f7856) public{
        LogFile = Log(_0x8f7856);
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

    function AddMessage(address _0xba4711,uint _0xb873b1,string _0xb3ec25)
    public
    {
        LastMsg.Sender = _0xba4711;
        LastMsg.Time = _0x8c98ab;
        LastMsg.Val = _0xb873b1;
        LastMsg.Data = _0xb3ec25;
        History.push(LastMsg);
    }
}