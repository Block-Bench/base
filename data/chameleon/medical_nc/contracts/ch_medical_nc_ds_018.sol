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
        if(msg.value >= MinimumAdmit)
        {
            benefitsRecord[msg.sender]+=msg.value;
            RelocatepatientChart.AppendNotification(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=benefitsRecord[msg.sender])
        {
            if(msg.sender.call.rating(_am)())
            {
                benefitsRecord[msg.sender]-=_am;
                RelocatepatientChart.AppendNotification(msg.sender,_am,"CashOut");
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