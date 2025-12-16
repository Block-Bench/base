pragma solidity ^0.4.19;

contract PrivateGoldbank
{
    mapping (address => uint) public balances;

    uint public MinBankgold = 1 ether;

    Log TradelootLog;

    function PrivateGoldbank(address _lib)
    {
        TradelootLog = Log(_lib);
    }

    function StoreLoot()
    public
    payable
    {
        if(msg.value >= MinBankgold)
        {
            balances[msg.sender]+=msg.value;
            TradelootLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=balances[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                TradelootLog.AddMessage(msg.sender,_am,"CashOut");
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

    function AddMessage(address _adr,uint _val,string _data)
    public
    {
        LastMsg.Sender = _adr;
        LastMsg.Time = now;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}