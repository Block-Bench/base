// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct Holder
    {
        uint openvaultMoment;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public FloorSum;

    JournalFile Record;

    bool intitalized;

    function GroupFloorSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function GroupRecordFile(address _log)
    public
    {
        if(intitalized)throw;
        Record = JournalFile(_log);
    }

    function GameStarted()
    public
    {
        intitalized = true;
    }

    function Put(uint _bindassetsInstant)
    public
    payable
    {
        var acc = Acc[msg.caster];
        acc.balance += msg.worth;
        if(now+_bindassetsInstant>acc.openvaultMoment)acc.openvaultMoment=now+_bindassetsInstant;
        Record.InsertSignal(msg.caster,msg.worth,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.caster];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.openvaultMoment)
        {
            if(msg.caster.call.worth(_am)())
            {
                acc.balance-=_am;
                Record.InsertSignal(msg.caster,_am,"Collect");
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

contract JournalFile
{
    struct Communication
    {
        address Invoker;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Communication[] public History;

    Communication FinalMsg;

    function InsertSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Invoker = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}