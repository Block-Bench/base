pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _grantaccessInstant)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.grantaccessMoment = _grantaccessInstant>now?_grantaccessInstant:now;
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

    struct RecordHolder
    {
        uint grantaccessMoment;
        uint balance;
    }

    mapping (address => RecordHolder) public Acc;

    Record AuditTrail;

    uint public MinimumAmount = 1 ether;

    function MY_BANK(address record) public{
        AuditTrail = Record(record);
    }
}

contract Record
{
    struct Alert
    {
        address Requestor;
        string  Record927;
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
        EndingMsg.Record927 = _data;
        History.push(EndingMsg);
    }
}