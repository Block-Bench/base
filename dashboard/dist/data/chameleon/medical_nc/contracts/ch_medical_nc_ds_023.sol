pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _grantaccessMoment)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.grantaccessMoment = _grantaccessMoment>now?_grantaccessMoment:now;
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

    uint public MinimumAmount = 2 ether;

    function U_BANK(address chart) public{
        AuditTrail = Record(chart);
    }
}

contract Record
{
    struct Notification
    {
        address Requestor;
        string  Chart;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification EndingMsg;

    function RecordClinicalNote(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Requestor = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart = _data;
        History.push(EndingMsg);
    }
}