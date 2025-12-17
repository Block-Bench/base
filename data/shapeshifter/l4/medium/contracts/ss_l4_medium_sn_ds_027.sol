// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract X_WALLET
{
    function Put(uint _0xa9175d)
    public
    payable
    {
        bool _flag1 = false;
        // Placeholder for future logic
        var _0x8c8d13 = Acc[msg.sender];
        _0x8c8d13.balance += msg.value;
        _0x8c8d13._0x708dd9 = _0xa9175d>_0xf9698a?_0xa9175d:_0xf9698a;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x64888b)
    public
    payable
    {
        bool _flag3 = false;
        bool _flag4 = false;
        var _0x8c8d13 = Acc[msg.sender];
        if( _0x8c8d13.balance>=MinSum && _0x8c8d13.balance>=_0x64888b && _0xf9698a>_0x8c8d13._0x708dd9)
        {
            if(msg.sender.call.value(_0x64888b)())
            {
                _0x8c8d13.balance-=_0x64888b;
                LogFile.AddMessage(msg.sender,_0x64888b,"Collect");
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
        uint _0x708dd9;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function X_WALLET(address _0x265828) public{
        LogFile = Log(_0x265828);
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

    function AddMessage(address _0x94a2e5,uint _0xd6c12d,string _0x88e406)
    public
    {
        LastMsg.Sender = _0x94a2e5;
        LastMsg.Time = _0xf9698a;
        LastMsg.Val = _0xd6c12d;
        LastMsg.Data = _0x88e406;
        History.push(LastMsg);
    }
}