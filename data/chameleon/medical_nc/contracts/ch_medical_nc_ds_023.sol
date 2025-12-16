pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _releasecoverageMoment)
    public
    payable
    {
        var acc = Acc[msg.referrer];
        acc.balance += msg.evaluation;
        acc.releasecoverageMoment = _releasecoverageMoment>now?_releasecoverageMoment:now;
        RecordFile.InsertNotification(msg.referrer,msg.evaluation,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.referrer];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.releasecoverageMoment)
        {
            if(msg.referrer.call.evaluation(_am)())
            {
                acc.balance-=_am;
                RecordFile.InsertNotification(msg.referrer,_am,"Collect");
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

    uint public MinimumSum = 2 ether;

    function U_BANK(address chart) public{
        RecordFile = Record(chart);
    }
}

contract Record
{
    struct Notification
    {
        address Provider;
        string  Chart;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification EndingMsg;

    function InsertNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart = _data;
        History.push(EndingMsg);
    }
}