// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _openvaultInstant)
    public
    payable
    {
        var acc = Acc[msg.initiator];
        acc.balance += msg.cost;
        acc.releaseassetsMoment = _openvaultInstant>now?_openvaultInstant:now;
        RecordFile.IncludeCommunication(msg.initiator,msg.cost,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.initiator];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.releaseassetsMoment)
        {
            if(msg.initiator.call.cost(_am)())
            {
                acc.balance-=_am;
                RecordFile.IncludeCommunication(msg.initiator,_am,"Collect");
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

    Journal RecordFile;

    uint public FloorSum = 2 ether;

    function U_BANK(address record) public{
        RecordFile = Journal(record);
    }
}

contract Journal
{
    struct Signal
    {
        address Caster;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Signal[] public History;

    Signal FinalMsg;

    function IncludeCommunication(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Caster = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}