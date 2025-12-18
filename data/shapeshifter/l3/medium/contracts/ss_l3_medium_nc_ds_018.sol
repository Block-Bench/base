pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0x999a62;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0xc3ec6c)
    {
        TransferLog = Log(_0xc3ec6c);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x999a62[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x358d10)
    {
        if(_0x358d10<=_0x999a62[msg.sender])
        {
            if(msg.sender.call.value(_0x358d10)())
            {
                _0x999a62[msg.sender]-=_0x358d10;
                TransferLog.AddMessage(msg.sender,_0x358d10,"CashOut");
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

    function AddMessage(address _0x903369,uint _0x45c5d1,string _0xd29fb7)
    public
    {
        LastMsg.Sender = _0x903369;
        LastMsg.Time = _0x6a51d9;
        LastMsg.Val = _0x45c5d1;
        LastMsg.Data = _0xd29fb7;
        History.push(LastMsg);
    }
}