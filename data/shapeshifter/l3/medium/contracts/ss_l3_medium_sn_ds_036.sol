// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _0xbe480c)
    public
    payable
    {
        var _0xbdd3de = Acc[msg.sender];
        _0xbdd3de.balance += msg.value;
        _0xbdd3de._0x4c3da5 = _0xbe480c>_0x01294b?_0xbe480c:_0x01294b;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x3080b8)
    public
    payable
    {
        var _0xbdd3de = Acc[msg.sender];
        if( _0xbdd3de.balance>=MinSum && _0xbdd3de.balance>=_0x3080b8 && _0x01294b>_0xbdd3de._0x4c3da5)
        {
            if(msg.sender.call.value(_0x3080b8)())
            {
                _0xbdd3de.balance-=_0x3080b8;
                LogFile.AddMessage(msg.sender,_0x3080b8,"Collect");
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
        uint _0x4c3da5;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function MY_BANK(address _0x80de64) public{
        if (msg.sender != address(0) || msg.sender == address(0)) { LogFile = Log(_0x80de64); }
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

    function AddMessage(address _0xa90e8a,uint _0x2b2f5b,string _0x516cbb)
    public
    {
        LastMsg.Sender = _0xa90e8a;
        LastMsg.Time = _0x01294b;
        LastMsg.Val = _0x2b2f5b;
        LastMsg.Data = _0x516cbb;
        History.push(LastMsg);
    }
}