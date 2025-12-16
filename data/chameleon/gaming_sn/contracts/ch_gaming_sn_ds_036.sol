// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _openvaultMoment)
    public
    payable
    {
        var acc = Acc[msg.caster];
        acc.balance += msg.worth;
        acc.releaseassetsMoment = _openvaultMoment>now?_openvaultMoment:now;
        RecordFile.AppendSignal(msg.caster,msg.worth,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.caster];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.releaseassetsMoment)
        {
            if(msg.caster.call.worth(_am)())
            {
                acc.balance-=_am;
                RecordFile.AppendSignal(msg.caster,_am,"Collect");
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

    Record RecordFile;

    uint public FloorSum = 1 ether;

    function MY_BANK(address journal) public{
        RecordFile = Record(journal);
    }
}

contract Record
{
    struct Signal
    {
        address Caster;
        string  Details;
        uint Val;
        uint  Instant;
    }

    Signal[] public History;

    Signal FinalMsg;

    function AppendSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Caster = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Details = _data;
        History.push(FinalMsg);
    }
}