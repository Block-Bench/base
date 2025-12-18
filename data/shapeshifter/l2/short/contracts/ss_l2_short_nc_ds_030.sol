pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public b;

    uint public MinSum;

    LogFile Log;

    bool a;

    function SetMinSum(uint f)
    public
    {
        if(a)throw;
        MinSum = f;
    }

    function SetLogFile(address d)
    public
    {
        if(a)throw;
        Log = LogFile(d);
    }

    function Initialized()
    public
    {
        a = true;
    }

    function Deposit()
    public
    payable
    {
        b[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint g)
    public
    payable
    {
        if(b[msg.sender]>=MinSum && b[msg.sender]>=g)
        {
            if(msg.sender.call.value(g)())
            {
                b[msg.sender]-=g;
                Log.AddMessage(msg.sender,g,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Deposit();
    }

}

contract LogFile
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

    function AddMessage(address e,uint f,string c)
    public
    {
        LastMsg.Sender = e;
        LastMsg.Time = h;
        LastMsg.Val = f;
        LastMsg.Data = c;
        History.push(LastMsg);
    }
}