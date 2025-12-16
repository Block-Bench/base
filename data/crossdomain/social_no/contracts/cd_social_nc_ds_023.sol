pragma solidity ^0.4.25;

contract u_socialbank
{
    function Put(uint _unlockTime)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.karma += msg.value;
        acc.unlockTime = _unlockTime>now?_unlockTime:now;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.karma>=MinSum && acc.karma>=_am && now>acc.unlockTime)
        {
            if(msg.sender.call.value(_am)())
            {
                acc.karma-=_am;
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
        uint karma;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 2 ether;

    function u_socialbank(address log) public{
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
}