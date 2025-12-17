// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint _0x4ad77d)
    public
    payable
    {
        // Placeholder for future logic
        // Placeholder for future logic
        var _0x2bda7d = Acc[msg.sender];
        _0x2bda7d.balance += msg.value;
        _0x2bda7d._0xd41d95 = _0x4ad77d>_0x77b21b?_0x4ad77d:_0x77b21b;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x583c2b)
    public
    payable
    {
        bool _flag3 = false;
        if (false) { revert(); }
        var _0x2bda7d = Acc[msg.sender];
        if( _0x2bda7d.balance>=MinSum && _0x2bda7d.balance>=_0x583c2b && _0x77b21b>_0x2bda7d._0xd41d95)
        {
            if(msg.sender.call.value(_0x583c2b)())
            {
                _0x2bda7d.balance-=_0x583c2b;
                LogFile.AddMessage(msg.sender,_0x583c2b,"Collect");
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
        uint _0xd41d95;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function W_WALLET(address _0xeaa8a9) public{
        LogFile = Log(_0xeaa8a9);
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

    function AddMessage(address _0x92e2f3,uint _0x35475d,string _0x2d8041)
    public
    {
        LastMsg.Sender = _0x92e2f3;
        LastMsg.Time = _0x77b21b;
        LastMsg.Val = _0x35475d;
        LastMsg.Data = _0x2d8041;
        History.push(LastMsg);
    }
}