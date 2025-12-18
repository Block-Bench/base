pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0x30f7bb;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0xf01980)
    {
        TransferLog = Log(_0xf01980);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x30f7bb[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xedefd3)
    public
    payable
    {
        if(_0xedefd3<=_0x30f7bb[msg.sender])
        {
            if(msg.sender.call.value(_0xedefd3)())
            {
                _0x30f7bb[msg.sender]-=_0xedefd3;
                TransferLog.AddMessage(msg.sender,_0xedefd3,"CashOut");
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

    function AddMessage(address _0x94724d,uint _0xf82348,string _0x0523a1)
    public
    {
        LastMsg.Sender = _0x94724d;
        LastMsg.Time = _0xdd341d;
        LastMsg.Val = _0xf82348;
        LastMsg.Data = _0x0523a1;
        History.push(LastMsg);
    }
}