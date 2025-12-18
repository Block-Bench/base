pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public a;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address d)
    {
        TransferLog = Log(d);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            a[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint f)
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

    function AddMessage(address c,uint e,string b)
    public
    {
        LastMsg.Sender = c;
        LastMsg.Time = g;
        LastMsg.Val = e;
        LastMsg.Data = b;
        History.push(LastMsg);
    }
}