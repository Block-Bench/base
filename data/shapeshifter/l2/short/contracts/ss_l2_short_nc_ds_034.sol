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

    function SetLogFile(address f)
    public
    {
        if(a)throw;
        LogFile = Log(f);
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
        var j = Acc[msg.sender];
        j.balance += msg.value;
        if(i+c>j.b)j.b=i+c;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint h)
    public
    payable
    {
        var j = Acc[msg.sender];
        if( j.balance>=MinSum && j.balance>=h && i>j.b)
        {
            if(msg.sender.call.value(h)())
            {
                j.balance-=h;
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

    function AddMessage(address e,uint g,string d)
    public
    {
        LastMsg.Sender = e;
        LastMsg.Time = i;
        LastMsg.Val = g;
        LastMsg.Data = d;
        History.push(LastMsg);
    }
}