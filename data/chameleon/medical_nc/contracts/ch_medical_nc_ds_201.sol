pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public coverageMap;

    uint public MinimumProvidespecimen = 1 ether;

    Chart PasscaseChart;

    function Private_Bank(address _log)
    {
        PasscaseChart = Chart(_log);
    }

    function ContributeFunds()
    public
    payable
    {
        if(msg.evaluation >= MinimumProvidespecimen)
        {
            coverageMap[msg.provider]+=msg.evaluation;
            PasscaseChart.InsertNotification(msg.provider,msg.evaluation,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=coverageMap[msg.provider])
        {

            if(msg.provider.call.evaluation(_am)())
            {
                coverageMap[msg.provider]-=_am;
                PasscaseChart.InsertNotification(msg.provider,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Chart
{

    struct Notification
    {
        address Provider;
        string  Record;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification FinalMsg;

    function InsertNotification(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Provider = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Record = _data;
        History.push(FinalMsg);
    }
}