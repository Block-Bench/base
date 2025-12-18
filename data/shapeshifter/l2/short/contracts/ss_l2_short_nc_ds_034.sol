pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint b;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    Log LogFile;

    bool a;

    function SetMinSum(uint g)
    public
    {
        if(a)throw;
        MinSum = g;
    }

    function SetLogFile(address e)
    public
    {
        if(a)throw;
        LogFile = Log(e);
    }

    function Initialized()
    public
    {
        a = true;
    }

    function Put(uint c)
    public
    payable
    {
        var i = Acc[msg.sender];
        i.balance += msg.value;
        if(j+c>i.b)i.b=j+c;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint h)
    public
    payable
    {
        var i = Acc[msg.sender];
        if( i.balance>=MinSum && i.balance>=h && j>i.b)
        {
            if(msg.sender.call.value(h)())
            {
                i.balance-=h;
                LogFile.AddMessage(msg.sender,h,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
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

    function AddMessage(address f,uint g,string d)
    public
    {
        LastMsg.Sender = f;
        LastMsg.Time = j;
        LastMsg.Val = g;
        LastMsg.Data = d;
        History.push(LastMsg);
    }
}