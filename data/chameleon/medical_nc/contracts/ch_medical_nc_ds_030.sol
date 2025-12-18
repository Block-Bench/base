pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public accountCreditsMap;

    uint public MinimumAmount;

    AuditTrail Chart;

    bool intitalized;

    function SetMinimumAmount(uint _val)
    public
    {
        if(intitalized)throw;
        MinimumAmount = _val;
    }

    function SetAuditTrail(address _log)
    public
    {
        if(intitalized)throw;
        Chart = AuditTrail(_log);
    }

    function SystemActivated()
    public
    {
        intitalized = true;
    }

    function SubmitPayment()
    public
    payable
    {
        accountCreditsMap[msg.sender]+= msg.value;
        Chart.RecordClinicalNote(msg.sender,msg.value,"Put");
    }

    function GatherBenefits(uint _am)
    public
    payable
    {
        if(accountCreditsMap[msg.sender]>=MinimumAmount && accountCreditsMap[msg.sender]>=_am)
        {
            if(msg.sender.call.value(_am)())
            {
                accountCreditsMap[msg.sender]-=_am;
                Chart.RecordClinicalNote(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        SubmitPayment();
    }

}

contract AuditTrail
{
    struct Notification
    {
        address Requestor;
        string  Record;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification FinalMsg;

    function RecordClinicalNote(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Requestor = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Record = _data;
        History.push(FinalMsg);
    }
}