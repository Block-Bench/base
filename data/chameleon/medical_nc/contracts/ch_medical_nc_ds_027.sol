pragma solidity ^0.4.25;

contract X_WALLET
{
    function Put(uint _releasecoverageMoment)
    public
    payable
    {
        var acc = Acc[msg.provider];
        acc.balance += msg.evaluation;
        acc.openrecordInstant = _releasecoverageMoment>now?_releasecoverageMoment:now;
        ChartFile.InsertAlert(msg.provider,msg.evaluation,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.provider];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.openrecordInstant)
        {
            if(msg.provider.call.evaluation(_am)())
            {
                acc.balance-=_am;
                ChartFile.InsertAlert(msg.provider,_am,"Collect");
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
        uint openrecordInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Record ChartFile;

    uint public FloorSum = 1 ether;

    function X_WALLET(address chart) public{
        ChartFile = Record(chart);
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

    function InsertAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart = _data;
        History.push(EndingMsg);
    }
}