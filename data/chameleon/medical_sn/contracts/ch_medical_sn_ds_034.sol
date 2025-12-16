// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint openrecordMoment;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public FloorSum;

    Chart RecordFile;

    bool intitalized;

    function CollectionFloorSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function CollectionRecordFile(address _log)
    public
    {
        if(intitalized)throw;
        RecordFile = Chart(_log);
    }

    function PatientAdmitted()
    public
    {
        intitalized = true;
    }

    function Put(uint _securerecordInstant)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        if(now+_securerecordInstant>acc.openrecordMoment)acc.openrecordMoment=now+_securerecordInstant;
        RecordFile.AppendNotification(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.openrecordMoment)
        {
            if(msg.sender.call.rating(_am)())
            {
                acc.balance-=_am;
                RecordFile.AppendNotification(msg.sender,_am,"Collect");
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
        address Referrer;
        string  Chart199;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification EndingMsg;

    function AppendNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart199 = _data;
        History.push(EndingMsg);
    }
}