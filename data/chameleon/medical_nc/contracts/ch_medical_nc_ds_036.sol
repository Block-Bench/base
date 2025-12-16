pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _releasecoverageInstant)
    public
    payable
    {
        var acc = Acc[msg.referrer];
        acc.balance += msg.rating;
        acc.releasecoverageMoment = _releasecoverageInstant>now?_releasecoverageInstant:now;
        RecordFile.AttachAlert(msg.referrer,msg.rating,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.referrer];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.releasecoverageMoment)
        {
            if(msg.referrer.call.rating(_am)())
            {
                acc.balance-=_am;
                RecordFile.AttachAlert(msg.referrer,_am,"Collect");
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
        uint releasecoverageMoment;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Record RecordFile;

    uint public MinimumSum = 1 ether;

    function MY_BANK(address record) public{
        RecordFile = Record(record);
    }
}

contract Record
{
    struct Notification
    {
        address Provider;
        string  Record124;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification EndingMsg;

    function AttachAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Record124 = _data;
        History.push(EndingMsg);
    }
}