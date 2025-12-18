pragma solidity ^0.4.19;

contract ACCURAL_DEPOSIT
{
    mapping (address=>uint256) public b;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool a;

    function SetMinSum(uint f)
    public
    {
        if(a)revert();
        MinSum = f;
    }

    function SetLogFile(address e)
    public
    {
        if(a)revert();
        Log = LogFile(e);
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

    function AddMessage(address d,uint f,string c)
    public
    {
        LastMsg.Sender = d;
        LastMsg.Time = h;
        LastMsg.Val = f;
        LastMsg.Data = c;
        History.push(LastMsg);
    }
}