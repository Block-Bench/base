pragma solidity ^0.4.19;

contract BENEFIT_ACCRUAL
{
    mapping (address=>uint256) public accountCreditsMap;

    uint public MinimumAmount = 1 ether;

    AuditTrail Chart = AuditTrail(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool intitalized;

    function SetMinimumAmount(uint _val)
    public
    {
        if(intitalized)revert();
        MinimumAmount = _val;
    }

    function SetAuditTrail(address _log)
    public
    {
        if(intitalized)revert();
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
        string  Info;
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
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}