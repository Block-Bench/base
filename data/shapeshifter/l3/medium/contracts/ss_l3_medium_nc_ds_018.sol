pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0x52de18;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0xdc4ec4)
    {
        TransferLog = Log(_0xdc4ec4);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x52de18[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xb4609c)
    {
        if(_0xb4609c<=_0x52de18[msg.sender])
        {
            if(msg.sender.call.value(_0xb4609c)())
            {
                _0x52de18[msg.sender]-=_0xb4609c;
                TransferLog.AddMessage(msg.sender,_0xb4609c,"CashOut");
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

    function AddMessage(address _0x55c446,uint _0x895b18,string _0x756a11)
    public
    {
        LastMsg.Sender = _0x55c446;
        LastMsg.Time = _0x81a1be;
        LastMsg.Val = _0x895b18;
        LastMsg.Data = _0x756a11;
        History.push(LastMsg);
    }
}