pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint a)
    public
    payable
    {
        var h = Acc[msg.sender];
        h.balance += msg.value;
        h.b = a>g?a:g;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint f)
    public
    payable
    {
        var h = Acc[msg.sender];
        if( h.balance>=MinSum && h.balance>=f && g>h.b)
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

    uint public MinSum = 1 ether;

    function MY_BANK(address i) public{
        LogFile = Log(i);
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
        LastMsg.Time = g;
        LastMsg.Val = e;
        LastMsg.Data = c;
        History.push(LastMsg);
    }
}