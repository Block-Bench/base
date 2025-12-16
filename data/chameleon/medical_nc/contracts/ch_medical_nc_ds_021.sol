pragma solidity ^0.4.19;

contract BANK_SAFE
{
    mapping (address=>uint256) public coverageMap;

    uint public MinimumSum;

    ChartFile Chart;

    bool intitalized;

    function GroupMinimumSum(uint _val)
    public
    {
        if(intitalized)throw;
        MinimumSum = _val;
    }

    function CollectionChartFile(address _log)
    public
    {
        if(intitalized)throw;
        Chart = ChartFile(_log);
    }

    function CaseOpened()
    public
    {
        intitalized = true;
    }

    function Admit()
    public
    payable
    {
        coverageMap[msg.referrer]+= msg.evaluation;
        Chart.AppendNotification(msg.referrer,msg.evaluation,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(coverageMap[msg.referrer]>=MinimumSum && coverageMap[msg.referrer]>=_am)
        {
            if(msg.referrer.call.evaluation(_am)())
            {
                coverageMap[msg.referrer]-=_am;
                Chart.AppendNotification(msg.referrer,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Admit();
    }

}

contract ChartFile
{
    struct Notification
    {
        address Provider;
        string  Record;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification EndingMsg;

    function AppendNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Record = _data;
        History.push(EndingMsg);
    }
}