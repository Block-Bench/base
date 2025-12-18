pragma solidity ^0.4.19;

contract PRIVATE_HEALTH_VAULT
{
    mapping (address=>uint256) public accountCreditsMap;

    uint public MinimumAmount;

    AuditTrail Record;

    bool intitalized;

    function SetMinimumAmount(uint _val)
    public
    {
        require(!intitalized);
        MinimumAmount = _val;
    }

    function SetAuditTrail(address _log)
    public
    {
        require(!intitalized);
        Record = AuditTrail(_log);
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
        Record.RecordClinicalNote(msg.sender,msg.value,"Put");
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
                Record.RecordClinicalNote(msg.sender,_am,"Collect");
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
        string  Chart;
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
        FinalMsg.Chart = _data;
        History.push(FinalMsg);
    }
}