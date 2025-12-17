// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract WALLET
{
    function Put(uint _0xb84530)
    public
    payable
    {
        var _0x3e0f19 = Acc[msg.sender];
        _0x3e0f19.balance += msg.value;
        _0x3e0f19._0x9b47ed = _0xb84530>_0x1e7200?_0xb84530:_0x1e7200;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xb953b9)
    public
    payable
    {
        var _0x3e0f19 = Acc[msg.sender];
        if( _0x3e0f19.balance>=MinSum && _0x3e0f19.balance>=_0xb953b9 && _0x1e7200>_0x3e0f19._0x9b47ed)
        {
            if(msg.sender.call.value(_0xb953b9)())
            {
                _0x3e0f19.balance-=_0xb953b9;
                LogFile.AddMessage(msg.sender,_0xb953b9,"Collect");
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
        uint _0x9b47ed;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function WALLET(address _0x2896a1) public{
        LogFile = Log(_0x2896a1);
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

    function AddMessage(address _0x4d141a,uint _0xe72b70,string _0x604d5d)
    public
    {
        LastMsg.Sender = _0x4d141a;
        LastMsg.Time = _0x1e7200;
        LastMsg.Val = _0xe72b70;
        LastMsg.Data = _0x604d5d;
        History.push(LastMsg);
    }
}