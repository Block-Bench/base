// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint a)
    public
    payable
    {
        var h = Acc[msg.sender];
        h.balance += msg.value;
        h.b = a>i?a:i;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint g)
    public
    payable
    {
        var h = Acc[msg.sender];
        if( h.balance>=MinSum && h.balance>=g && i>h.b)
        {
            if(msg.sender.call.value(g)())
            {
                h.balance-=g;
                LogFile.AddMessage(msg.sender,g,"Collect");
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
        uint b;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function W_WALLET(address f) public{
        LogFile = Log(f);
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

    function AddMessage(address e,uint d,string c)
    public
    {
        LastMsg.Sender = e;
        LastMsg.Time = i;
        LastMsg.Val = d;
        LastMsg.Data = c;
        History.push(LastMsg);
    }
}