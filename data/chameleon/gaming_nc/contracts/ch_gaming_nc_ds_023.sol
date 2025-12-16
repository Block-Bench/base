pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _releaseassetsInstant)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.releaseassetsInstant = _releaseassetsInstant>now?_releaseassetsInstant:now;
        JournalFile.IncludeSignal(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.releaseassetsInstant)
        {
            if(msg.sender.call.cost(_am)())
            {
                acc.balance-=_am;
                JournalFile.IncludeSignal(msg.sender,_am,"Collect");
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