pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint _releasecoverageInstant)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.openrecordInstant = _releasecoverageInstant>now?_releasecoverageInstant:now;
        ChartFile.AppendAlert(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.openrecordInstant)
        {
            if(msg.sender.call.evaluation(_am)())
            {
                acc.balance-=_am;
                ChartFile.AppendAlert(msg.sender,_am,"Collect");
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

    function W_WALLET(address chart) public{
        ChartFile = Record(chart);
    }
}

contract Record
{
    struct Notification
    {
        address Provider;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification EndingMsg;

    function AppendAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}