pragma solidity ^0.4.19;

contract eth_goldvault
{
    mapping (address => uint) public balances;

    uint public MinStoreloot = 1 ether;

    Log SharetreasureLog;

    function eth_goldvault(address _log)
    public
    {
        SharetreasureLog = Log(_log);
    }

    function CacheTreasure()
    public
    payable
    {
        if(msg.value > MinStoreloot)
        {
            balances[msg.sender]+=msg.value;
            SharetreasureLog.AddMessage(msg.sender,msg.value,"Deposit");
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
                SharetreasureLog.AddMessage(msg.sender,_am,"CashOut");
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