pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public accountCreditsMap;

    uint public MinimumPayment = 1 ether;

    Record TransfercareRecord;

    function Private_Bank(address _log)
    {
        TransfercareRecord = Record(_log);
    }

    function SubmitPayment()
    public
    payable
    {
        if(msg.value > MinimumPayment)
        {
            accountCreditsMap[msg.sender]+=msg.value;
            TransfercareRecord.RecordClinicalNote(msg.sender,msg.value,"Deposit");
        }
    }

    function WithdrawBenefits(uint _am)
    public
    payable
    {
        if(_am<=accountCreditsMap[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                accountCreditsMap[msg.sender]-=_am;
                TransfercareRecord.RecordClinicalNote(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Notification
    {
        address Requestor;
        string  Record662;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification FinalMsg;

    function RecordClinicalNote(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Requestor = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Record662 = _data;
        History.push(FinalMsg);
    }
}