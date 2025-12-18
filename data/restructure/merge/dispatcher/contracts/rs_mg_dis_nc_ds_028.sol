pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public balances;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    uint lastBlock;

    function ETH_FUND(address _log)
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
                TransferLog.AddMessage(msg.sender,_am,"CashOut");
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

    // Unified dispatcher - merged from: CashOut, ETH_FUND, Deposit
    // Selectors: CashOut=0, ETH_FUND=1, Deposit=2
    function execute(uint8 _selector, address _log, uint _am) public payable {
        // Original: CashOut()
        if (_selector == 0) {
            if(_am<=balances[msg.sender]&&block.number>lastBlock)
            {
            if(msg.sender.call.value(_am)())
            {
            balances[msg.sender]-=_am;
            TransferLog.AddMessage(msg.sender,_am,"CashOut");
            }
            }
        }
        // Original: ETH_FUND()
        else if (_selector == 1) {
            TransferLog = Log(_log);
        }
        // Original: Deposit()
        else if (_selector == 2) {
            if(msg.value > MinDeposit)
            {
            balances[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
            lastBlock = block.number;
            }
        }
    }
}