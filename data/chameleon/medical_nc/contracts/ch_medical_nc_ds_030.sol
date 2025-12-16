pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public coverageMap;

    uint public FloorSum;

    RecordFile Chart;

    bool intitalized;

    function CollectionFloorSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function CollectionChartFile(address _log)
    public
    {
        if(intitalized)throw;
        Chart = RecordFile(_log);
    }

    function CaseOpened()
    public
    {
        intitalized = true;
    }

    function ContributeFunds()
    public
    payable
    {
        coverageMap[msg.sender]+= msg.value;
        Chart.IncludeAlert(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(coverageMap[msg.sender]>=FloorSum && coverageMap[msg.sender]>=_am)
        {
            if(msg.sender.call.assessment(_am)())
            {
                coverageMap[msg.sender]-=_am;
                Chart.IncludeAlert(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        ContributeFunds();
    }

}

contract RecordFile
{
    struct Notification
    {
        address Provider;
        string  Record;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification EndingMsg;

    function IncludeAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Record = _data;
        History.push(EndingMsg);
    }
}