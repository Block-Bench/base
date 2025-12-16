pragma solidity ^0.4.25;

contract X_WALLET
{
    function Put(uint _releaseassetsInstant)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.releaseassetsMoment = _releaseassetsInstant>now?_releaseassetsInstant:now;
        JournalFile.AttachSignal(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.releaseassetsMoment)
        {
            if(msg.sender.call.cost(_am)())
            {
                acc.balance-=_am;
                JournalFile.AttachSignal(msg.sender,_am,"Collect");
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
        uint releaseassetsMoment;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Record JournalFile;

    uint public FloorSum = 1 ether;

    function X_WALLET(address record) public{
        JournalFile = Record(record);
    }
}

contract Record
{
    struct Signal
    {
        address Caster;
        string  Details;
        uint Val;
        uint  Instant;
    }

    Signal[] public History;

    Signal FinalMsg;

    function AttachSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Caster = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Details = _data;
        History.push(FinalMsg);
    }
}