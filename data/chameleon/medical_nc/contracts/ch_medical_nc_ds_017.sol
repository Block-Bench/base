pragma solidity ^0.4.19;

contract PATIENT_ACCOUNT
{
    mapping (address=>uint256) public accountCreditsMap;

    uint public MinimumAmount = 1 ether;

    AuditTrail Record = AuditTrail(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

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
    struct Alert
    {
        address Requestor;
        string  Record49;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function RecordClinicalNote(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Requestor = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Record49 = _data;
        History.push(EndingMsg);
    }
}