pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _unlockTime)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.unlockTime = _unlockTime>now?_unlockTime:now;
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

    struct Holder
    {
        uint unlockTime;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function MY_BANK(address log) public{
        LogFile = Log(log);
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

    // Unified dispatcher - merged from: Collect, Put, MY_BANK
    // Selectors: Collect=0, Put=1, MY_BANK=2
    function execute(uint8 _selector, address log, uint _am, uint _unlockTime) public payable {
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
        // Original: Put()
        else if (_selector == 1) {
            var acc = Acc[msg.sender];
            acc.balance += msg.value;
            acc.unlockTime = _unlockTime>now?_unlockTime:now;
            LogFile.AddMessage(msg.sender,msg.value,"Put");
        }
        // Original: MY_BANK()
        else if (_selector == 2) {
            LogFile = Log(log);
        }
    }
}