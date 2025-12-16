pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _releasecoverageMoment)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.releasecoverageMoment = _releasecoverageMoment>now?_releasecoverageMoment:now;
        RecordFile.InsertNotification(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.releasecoverageMoment)
        {
            if(msg.sender.call.evaluation(_am)())
            {
                acc.balance-=_am;
                RecordFile.InsertNotification(msg.sender,_am,"Collect");
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