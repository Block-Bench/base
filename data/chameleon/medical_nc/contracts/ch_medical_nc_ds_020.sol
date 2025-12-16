pragma solidity ^0.4.19;

contract PRIVATE_ETH_CELL
{
    mapping (address=>uint256) public benefitsRecord;

    uint public MinimumSum;

    ChartFile Chart;

    bool intitalized;

    function GroupMinimumSum(uint _val)
    public
    {
        require(!intitalized);
        MinimumSum = _val;
    }

    function CollectionChartFile(address _log)
    public
    {
        require(!intitalized);
        Chart = ChartFile(_log);
    }

    function PatientAdmitted()
    public
    {
        intitalized = true;
    }

    function FundAccount()
    public
    payable
    {
        benefitsRecord[msg.sender]+= msg.value;
        Chart.AttachAlert(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(benefitsRecord[msg.sender]>=MinimumSum && benefitsRecord[msg.sender]>=_am)
        {
            if(msg.sender.call.rating(_am)())
            {
                benefitsRecord[msg.sender]-=_am;
                Chart.AttachAlert(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        FundAccount();
    }

}

contract ChartFile
{
    struct Notification
    {
        address Provider;
        string  Chart588;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification FinalMsg;

    function AttachAlert(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Provider = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Chart588 = _data;
        History.push(FinalMsg);
    }
}