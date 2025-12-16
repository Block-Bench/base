// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint _releaseassetsMoment)
    public
    payable
    {
        var acc = Acc[msg.initiator];
        acc.balance += msg.cost;
        acc.releaseassetsMoment = _releaseassetsMoment>now?_releaseassetsMoment:now;
        JournalFile.AppendSignal(msg.initiator,msg.cost,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.initiator];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.releaseassetsMoment)
        {
            if(msg.initiator.call.cost(_am)())
            {
                acc.balance-=_am;
                JournalFile.AppendSignal(msg.initiator,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
    }

    struct Holder
    {
        uint releaseassetsMoment;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Record JournalFile;

    uint public MinimumSum = 1 ether;

    function W_WALLET(address record) public{
        JournalFile = Record(record);
    }
}

contract Record
{
    struct Signal
    {
        address Caster;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Signal[] public History;

    Signal EndingMsg;

    function AppendSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Caster = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}