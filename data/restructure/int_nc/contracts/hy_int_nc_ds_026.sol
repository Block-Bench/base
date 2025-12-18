pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public balances;

    Log TransferLog;

    uint public MinDeposit = 1 ether;

    function ETH_VAULT(address _log)
    public
    {
        TransferLog = Log(_log);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            balances[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        _handleCashOutCore(msg.sender, _am);
    }

    function _handleCashOutCore(address _sender, uint _am) internal {
        if(_am<=balances[_sender])
        {
        if(_sender.call.value(_am)())
        {
        balances[_sender]-=_am;
        TransferLog.AddMessage(_sender,_am,"CashOut");
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