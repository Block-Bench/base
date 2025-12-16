pragma solidity ^0.4.19;

contract private_socialbank
{
    mapping (address => uint) public balances;

    uint public MinContribute = 1 ether;

    Log GivecreditLog;

    function private_socialbank(address _log)
    {
        GivecreditLog = Log(_log);
    }

    function Fund()
    public
    payable
    {
        if(msg.value >= MinContribute)
        {
            balances[msg.sender]+=msg.value;
            GivecreditLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
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