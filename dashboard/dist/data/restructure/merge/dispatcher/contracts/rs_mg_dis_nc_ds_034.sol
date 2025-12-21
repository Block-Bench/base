pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint unlockTime;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    Log LogFile;

    bool intitalized;

    function SetMinSum(uint _val)
    public
    {
        if(intitalized)throw;
        MinSum = _val;
    }

    function SetLogFile(address _log)
    public
    {
        if(intitalized)throw;
        LogFile = Log(_log);
    }

    function Initialized()
    public
    {
        intitalized = true;
    }

    function Put(uint _lockTime)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        if(now+_lockTime>acc.unlockTime)acc.unlockTime=now+_lockTime;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime)
        {
            if(msg.sender.call.value(_am)())
            {
                acc.balance-=_am;
                LogFile.AddMessage(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
    }

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

    // Unified dispatcher - merged from: Collect, SetMinSum, SetLogFile
    // Selectors: Collect=0, SetMinSum=1, SetLogFile=2
    function execute(uint8 _selector, address _log, uint _am, uint _val) public payable {
        // Original: Collect()
        if (_selector == 0) {
            var acc = Acc[msg.sender];
            if( acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime)
            {
            if(msg.sender.call.value(_am)())
            {
            acc.balance-=_am;
            LogFile.AddMessage(msg.sender,_am,"Collect");
            }
            }
        }
        // Original: SetMinSum()
        else if (_selector == 1) {
            if(intitalized)throw;
            MinSum = _val;
        }
        // Original: SetLogFile()
        else if (_selector == 2) {
            if(intitalized)throw;
            LogFile = Log(_log);
        }
    }
}