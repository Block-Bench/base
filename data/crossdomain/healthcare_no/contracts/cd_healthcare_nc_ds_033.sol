pragma solidity ^0.4.19;

contract eth_coveragevault
{
    mapping (address => uint) public balances;

    uint public MinContributepremium = 1 ether;

    Log AssigncreditLog;

    function eth_coveragevault(address _log)
    public
    {
        AssigncreditLog = Log(_log);
    }

    function FundAccount()
    public
    payable
    {
        if(msg.value > MinContributepremium)
        {
            balances[msg.sender]+=msg.value;
            AssigncreditLog.AddMessage(msg.sender,msg.value,"Deposit");
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
                AssigncreditLog.AddMessage(msg.sender,_am,"CashOut");
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