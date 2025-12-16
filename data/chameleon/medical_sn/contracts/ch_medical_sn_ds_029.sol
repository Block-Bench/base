// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct Holder
    {
        uint releasecoverageInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public FloorSum;

    RecordFile Record;

    bool intitalized;

    function CollectionMinimumSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function CollectionRecordFile(address _log)
    public
    {
        if(intitalized)throw;
        Record = RecordFile(_log);
    }

    function PatientAdmitted()
    public
    {
        intitalized = true;
    }

    function Put(uint _bindcoverageMoment)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        if(now+_bindcoverageMoment>acc.releasecoverageInstant)acc.releasecoverageInstant=now+_bindcoverageMoment;
        Record.AppendNotification(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.releasecoverageInstant)
        {
            if(msg.sender.call.evaluation(_am)())
            {
                acc.balance-=_am;
                Record.AppendNotification(msg.sender,_am,"Collect");
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

contract RecordFile
{
    struct Alert
    {
        address Referrer;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function AppendNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}