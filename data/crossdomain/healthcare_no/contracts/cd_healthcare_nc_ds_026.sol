pragma solidity ^0.4.19;

contract eth_patientvault
{
    mapping (address => uint) public balances;

    Log SharebenefitLog;

    uint public MinPaypremium = 1 ether;

    function eth_patientvault(address _log)
    public
    {
        SharebenefitLog = Log(_log);
    }

    function ContributePremium()
    public
    payable
    {
        if(msg.value > MinPaypremium)
        {
            balances[msg.sender]+=msg.value;
            SharebenefitLog.AddMessage(msg.sender,msg.value,"Deposit");
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
                SharebenefitLog.AddMessage(msg.sender,_am,"CashOut");
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