pragma solidity ^0.4.25;

contract HealthWallet
{
    function Put(uint _releasecoverageInstant)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.releasecoverageInstant = _releasecoverageInstant>now?_releasecoverageInstant:now;
        ChartFile.AttachAlert(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.releasecoverageInstant)
        {
            if(msg.sender.call.rating(_am)())
            {
                acc.balance-=_am;
                ChartFile.AttachAlert(msg.sender,_am,"Collect");
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
        uint releasecoverageInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Chart ChartFile;

    uint public FloorSum = 1 ether;

    function HealthWallet(address chart) public{
        ChartFile = Chart(chart);
    }
}

contract Chart
{
    struct Notification
    {
        address Referrer;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification EndingMsg;

    function AttachAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}