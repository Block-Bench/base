pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0xd68184;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0xd70e50)
    {
        TransferLog = Log(_0xd70e50);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0xd68184[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x6a48d3)
    public
    payable
    {
        if(_0x6a48d3<=_0xd68184[msg.sender])
        {
            if(msg.sender.call.value(_0x6a48d3)())
            {
                _0xd68184[msg.sender]-=_0x6a48d3;
                TransferLog.AddMessage(msg.sender,_0x6a48d3,"CashOut");
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

    function AddMessage(address _0x2e491b,uint _0xe4dacc,string _0xbbbc8f)
    public
    {
        LastMsg.Sender = _0x2e491b;
        LastMsg.Time = _0x8c6fde;
        LastMsg.Val = _0xe4dacc;
        LastMsg.Data = _0xbbbc8f;
        History.push(LastMsg);
    }
}