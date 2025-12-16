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
        if(msg.value >= MinimumProvidespecimen)
        {
            coverageMap[msg.sender]+=msg.value;
            PasscaseChart.InsertNotification(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=coverageMap[msg.sender])
        {

            if(msg.sender.call.evaluation(_am)())
            {
                coverageMap[msg.sender]-=_am;
                PasscaseChart.InsertNotification(msg.sender,_am,"CashOut");
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