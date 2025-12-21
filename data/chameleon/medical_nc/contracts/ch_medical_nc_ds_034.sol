pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct RecordHolder
    {
        uint grantaccessMoment;
        uint balance;
    }

    mapping (address => RecordHolder) public Acc;

    uint public MinimumAmount;

    Chart AuditTrail;

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
        AuditTrail = Chart(_log);
    }

    function SystemActivated()
    public
    {
        intitalized = true;
    }

    function Put(uint _restrictaccessMoment)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        if(now+_restrictaccessMoment>acc.grantaccessMoment)acc.grantaccessMoment=now+_restrictaccessMoment;
        AuditTrail.RecordClinicalNote(msg.sender,msg.value,"Put");
    }

    function GatherBenefits(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=MinimumAmount && acc.balance>=_am && now>acc.grantaccessMoment)
        {
            if(msg.sender.call.value(_am)())
            {
                acc.balance-=_am;
                AuditTrail.RecordClinicalNote(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
    }

}

contract Chart
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