pragma solidity ^0.4.25;

contract U_BANK
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

    function Collect(uint f)
    public
    payable
    {
        var h = Acc[msg.sender];
        if( h.balance>=MinSum && h.balance>=f && i>h.b)
        {
            if(msg.sender.call.value(f)())
            {
                h.balance-=f;
                LogFile.AddMessage(msg.sender,f,"Collect");
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

    uint public MinSum = 2 ether;

    function U_BANK(address g) public{
        LogFile = Log(g);
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

    function AddMessage(address d,uint e,string c)
    public
    {
        LastMsg.Sender = d;
        LastMsg.Time = i;
        LastMsg.Val = e;
        LastMsg.Data = c;
        History.push(LastMsg);
    }
}