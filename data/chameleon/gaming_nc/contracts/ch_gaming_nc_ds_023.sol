pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _releaseassetsInstant)
    public
    payable
    {
        var acc = Acc[msg.caster];
        acc.balance += msg.cost;
        acc.releaseassetsInstant = _releaseassetsInstant>now?_releaseassetsInstant:now;
        JournalFile.IncludeSignal(msg.caster,msg.cost,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.caster];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.releaseassetsInstant)
        {
            if(msg.caster.call.cost(_am)())
            {
                acc.balance-=_am;
                JournalFile.IncludeSignal(msg.caster,_am,"Collect");
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
        uint releaseassetsInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Record JournalFile;

    uint public MinimumSum = 2 ether;

    function U_BANK(address record) public{
        JournalFile = Record(record);
    }
}

contract Record
{
    struct Signal
    {
        address Invoker;
        string  Details;
        uint Val;
        uint  Instant;
    }

    Signal[] public History;

    Signal EndingMsg;

    function IncludeSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Invoker = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Details = _data;
        History.push(EndingMsg);
    }
}