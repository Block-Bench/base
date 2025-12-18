pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0x2783db;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0x7440f5)
    {
        TransferLog = Log(_0x7440f5);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x2783db[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x9182a2)
    {
        if(_0x9182a2<=_0x2783db[msg.sender])
        {
            if(msg.sender.call.value(_0x9182a2)())
            {
                _0x2783db[msg.sender]-=_0x9182a2;
                TransferLog.AddMessage(msg.sender,_0x9182a2,"CashOut");
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

    function AddMessage(address _0x1d249c,uint _0x03d3d4,string _0x75ed42)
    public
    {
        LastMsg.Sender = _0x1d249c;
        LastMsg.Time = _0x81d2e5;
        LastMsg.Val = _0x03d3d4;
        LastMsg.Data = _0x75ed42;
        History.push(LastMsg);
    }
}