pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public benefitsRecord;

    uint public MinimumAdmit = 1 ether;

    Chart RelocatepatientChart;

    function PrivateBank(address _log)
    {
        RelocatepatientChart = Chart(_log);
    }

    function ContributeFunds()
    public
    payable
    {
        if(msg.rating >= MinimumAdmit)
        {
            benefitsRecord[msg.referrer]+=msg.rating;
            RelocatepatientChart.AppendNotification(msg.referrer,msg.rating,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=benefitsRecord[msg.referrer])
        {
            if(msg.referrer.call.rating(_am)())
            {
                benefitsRecord[msg.referrer]-=_am;
                RelocatepatientChart.AppendNotification(msg.referrer,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Chart
{

    struct Alert
    {
        address Referrer;
        string  Record;
        uint Val;
        uint  Moment;
    }

    Alert[] public History;

    Alert FinalMsg;

    function AppendNotification(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Referrer = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Record = _data;
        History.push(FinalMsg);
    }
}