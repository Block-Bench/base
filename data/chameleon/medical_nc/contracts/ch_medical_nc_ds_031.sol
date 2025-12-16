pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public coverageMap;

    uint public FloorAdmit = 1 ether;

    Record ReferChart;

    function Private_Bank(address _log)
    {
        ReferChart = Record(_log);
    }

    function Admit()
    public
    payable
    {
        if(msg.rating > FloorAdmit)
        {
            coverageMap[msg.provider]+=msg.rating;
            ReferChart.AttachNotification(msg.provider,msg.rating,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=coverageMap[msg.provider])
        {
            if(msg.provider.call.rating(_am)())
            {
                coverageMap[msg.provider]-=_am;
                ReferChart.AttachNotification(msg.provider,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Notification
    {
        address Referrer;
        string  Chart;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification FinalMsg;

    function AttachNotification(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Referrer = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Chart = _data;
        History.push(FinalMsg);
    }
}