pragma solidity ^0.4.19;

contract private_tipbank
{
    mapping (address => uint) public balances;

    uint public MinTip = 1 ether;

    Log GivecreditLog;

    function private_tipbank(address _log)
    {
        GivecreditLog = Log(_log);
    }

    function Tip()
    public
    payable
    {
        if(msg.value > MinTip)
        {
            balances[msg.sender]+=msg.value;
            GivecreditLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=balances[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                GivecreditLog.AddMessage(msg.sender,_am,"CashOut");
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