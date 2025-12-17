// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract X_WALLET
{
    function Put(uint _0x078bee)
    public
    payable
    {
        var _0xde1c39 = Acc[msg.sender];
        _0xde1c39.balance += msg.value;
        _0xde1c39._0xaaff77 = _0x078bee>_0x8fc29b?_0x078bee:_0x8fc29b;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xd2fd60)
    public
    payable
    {
        var _0xde1c39 = Acc[msg.sender];
        if( _0xde1c39.balance>=MinSum && _0xde1c39.balance>=_0xd2fd60 && _0x8fc29b>_0xde1c39._0xaaff77)
        {
            if(msg.sender.call.value(_0xd2fd60)())
            {
                _0xde1c39.balance-=_0xd2fd60;
                LogFile.AddMessage(msg.sender,_0xd2fd60,"Collect");
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
        uint _0xaaff77;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function X_WALLET(address _0xe5b2da) public{
        LogFile = Log(_0xe5b2da);
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

    function AddMessage(address _0x1b330d,uint _0x8c94c6,string _0x292e8b)
    public
    {
        LastMsg.Sender = _0x1b330d;
        LastMsg.Time = _0x8fc29b;
        LastMsg.Val = _0x8c94c6;
        LastMsg.Data = _0x292e8b;
        History.push(LastMsg);
    }
}