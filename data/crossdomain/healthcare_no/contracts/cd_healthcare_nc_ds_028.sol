pragma solidity ^0.4.19;

contract eth_coveragefund
{
    mapping (address => uint) public balances;

    uint public MinFundaccount = 1 ether;

    Log TransferbenefitLog;

    uint lastBlock;

    function eth_coveragefund(address _log)
    public
    {
        TransferbenefitLog = Log(_log);
    }

    function FundAccount()
    public
    payable
    {
        if(msg.value > MinFundaccount)
        {
            balances[msg.sender]+=msg.value;
            TransferbenefitLog.AddMessage(msg.sender,msg.value,"Deposit");
            lastBlock = block.number;
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=balances[msg.sender]&&block.number>lastBlock)
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                TransferbenefitLog.AddMessage(msg.sender,_am,"CashOut");
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