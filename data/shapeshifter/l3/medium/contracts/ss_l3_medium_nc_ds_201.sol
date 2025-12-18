pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public _0x7b9b15;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function Private_Bank(address _0x76729b)
    {
        TransferLog = Log(_0x76729b);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value >= MinDeposit)
        {
            _0x7b9b15[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xf4cb7f)
    {
        if(_0xf4cb7f<=_0x7b9b15[msg.sender])
        {

            if(msg.sender.call.value(_0xf4cb7f)())
            {
                _0x7b9b15[msg.sender]-=_0xf4cb7f;
                TransferLog.AddMessage(msg.sender,_0xf4cb7f,"CashOut");
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

    function AddMessage(address _0x11fb3e,uint _0x2d7fff,string _0x4e3feb)
    public
    {
        LastMsg.Sender = _0x11fb3e;
        LastMsg.Time = _0xaa1191;
        LastMsg.Val = _0x2d7fff;
        LastMsg.Data = _0x4e3feb;
        History.push(LastMsg);
    }
}