pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public a;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address c)
    {
        TransferLog = Log(c);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            a[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint f)
    public
    payable
    {
        if(f<=a[msg.sender])
        {
            if(msg.sender.call.value(f)())
            {
                a[msg.sender]-=f;
                TransferLog.AddMessage(msg.sender,f,"CashOut");
            }
        }
    }

    function() public payable{}

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

    function AddMessage(address d,uint e,string b)
    public
    {
        LastMsg.Sender = d;
        LastMsg.Time = g;
        LastMsg.Val = e;
        LastMsg.Data = b;
        History.push(LastMsg);
    }
}