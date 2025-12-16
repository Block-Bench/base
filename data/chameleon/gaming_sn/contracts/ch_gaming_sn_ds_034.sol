// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint openvaultMoment;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public FloorSum;

    Record RecordFile;

    bool intitalized;

    function GroupMinimumSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function GroupJournalFile(address _log)
    public
    {
        if(intitalized)throw;
        RecordFile = Record(_log);
    }

    function GameStarted()
    public
    {
        intitalized = true;
    }

    function Put(uint _bindassetsMoment)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        if(now+_bindassetsMoment>acc.openvaultMoment)acc.openvaultMoment=now+_bindassetsMoment;
        RecordFile.AppendCommunication(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.openvaultMoment)
        {
            if(msg.sender.call.worth(_am)())
            {
                acc.balance-=_am;
                RecordFile.AppendCommunication(msg.sender,_am,"Collect");
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

contract Record
{
    struct Communication
    {
        address Invoker;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Communication[] public History;

    Communication EndingMsg;

    function AppendCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Invoker = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}