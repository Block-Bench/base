pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0x2445b3;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0xa88826)
    {
        TransferLog = Log(_0xa88826);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x2445b3[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x892ad8)
    {
        if(_0x892ad8<=_0x2445b3[msg.sender])
        {
            if(msg.sender.call.value(_0x892ad8)())
            {
                _0x2445b3[msg.sender]-=_0x892ad8;
                TransferLog.AddMessage(msg.sender,_0x892ad8,"CashOut");
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

    function AddMessage(address _0xe5efc9,uint _0x9fd7eb,string _0x79de16)
    public
    {
        LastMsg.Sender = _0xe5efc9;
        LastMsg.Time = _0x1dba80;
        LastMsg.Val = _0x9fd7eb;
        LastMsg.Data = _0x79de16;
        History.push(LastMsg);
    }
}