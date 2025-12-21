pragma solidity ^0.4.19;

contract PrivateHealthAccount
{
    mapping (address => uint) public accountCreditsMap;

    uint public MinimumPayment = 1 ether;

    Chart TransfercareChart;

    function PrivateHealthAccount(address _log)
    {
        TransfercareChart = Chart(_log);
    }

    function SubmitPayment()
    public
    payable
    {
        if(msg.value >= MinimumPayment)
        {
            accountCreditsMap[msg.sender]+=msg.value;
            TransfercareChart.RecordClinicalNote(msg.sender,msg.value,"Deposit");
        }
    }

    function WithdrawBenefits(uint _am)
    {
        if(_am<=accountCreditsMap[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                accountCreditsMap[msg.sender]-=_am;
                TransfercareChart.RecordClinicalNote(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Chart
{

    struct Alert
    {
        address Requestor;
        string  Record;
        uint Val;
        uint  Moment;
    }

    Alert[] public History;

    Alert FinalMsg;

    function RecordClinicalNote(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Requestor = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Record = _data;
        History.push(FinalMsg);
    }
}