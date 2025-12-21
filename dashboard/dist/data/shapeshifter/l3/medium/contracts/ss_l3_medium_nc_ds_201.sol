pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0x180cef;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0xb5b610)
    {
        TransferLog = Log(_0xb5b610);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x180cef[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x6020ef)
    {
        if(_0x6020ef<=_0x180cef[msg.sender])
        {

            if(msg.sender.call.value(_0x6020ef)())
            {
                _0x180cef[msg.sender]-=_0x6020ef;
                TransferLog.AddMessage(msg.sender,_0x6020ef,"CashOut");
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

    function AddMessage(address _0xeb0529,uint _0x51564b,string _0xc4574d)
    public
    {
        LastMsg.Sender = _0xeb0529;
        LastMsg.Time = _0xf33a8e;
        LastMsg.Val = _0x51564b;
        LastMsg.Data = _0xc4574d;
        History.push(LastMsg);
    }
}