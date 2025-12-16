pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint releasecoverageInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinimumSum;

    Chart ChartFile;

    bool intitalized;

    function CollectionFloorSum(uint _val)
    public
    {
        if(intitalized)throw;
        MinimumSum = _val;
    }

    function CollectionChartFile(address _log)
    public
    {
        if(intitalized)throw;
        ChartFile = Chart(_log);
    }

    function CaseOpened()
    public
    {
        intitalized = true;
    }

    function Put(uint _freezeaccountMoment)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        if(now+_freezeaccountMoment>acc.releasecoverageInstant)acc.releasecoverageInstant=now+_freezeaccountMoment;
        ChartFile.AppendNotification(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.releasecoverageInstant)
        {
            if(msg.sender.call.evaluation(_am)())
            {
                acc.balance-=_am;
                ChartFile.AppendNotification(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
    }

}

contract Chart
{
    struct Notification
    {
        address Referrer;
        string  Chart124;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification EndingMsg;

    function AppendNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart124 = _data;
        History.push(EndingMsg);
    }
}