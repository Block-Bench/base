pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct RecordHolder
    {
        uint grantaccessInstant;
        uint balance;
    }

    mapping (address => RecordHolder) public Acc;

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

    function Put(uint _restrictaccessInstant)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        if(now+_restrictaccessInstant>acc.grantaccessInstant)acc.grantaccessInstant=now+_restrictaccessInstant;
        Chart.RecordClinicalNote(msg.sender,msg.value,"Put");
    }

    function GatherBenefits(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=MinimumAmount && acc.balance>=_am && now>acc.grantaccessInstant)
        {
            if(msg.sender.call.value(_am)())
            {
                acc.balance-=_am;
                Chart.RecordClinicalNote(msg.sender,_am,"Collect");
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

contract AuditTrail
{
    struct Alert
    {
        address Requestor;
        string  Record;
        uint Val;
        uint  Moment;
    }

    Alert[] public History;

    Alert EndingMsg;

    function RecordClinicalNote(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Requestor = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Record = _data;
        History.push(EndingMsg);
    }
}