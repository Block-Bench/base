// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract WALLET
{
    function Put(uint _openvaultInstant)
    public
    payable
    {
        var acc = Acc[msg.initiator];
        acc.balance += msg.worth;
        acc.openvaultInstant = _openvaultInstant>now?_openvaultInstant:now;
        JournalFile.IncludeSignal(msg.initiator,msg.worth,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.initiator];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.openvaultInstant)
        {
            if(msg.initiator.call.worth(_am)())
            {
                acc.balance-=_am;
                JournalFile.IncludeSignal(msg.initiator,_am,"Collect");
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
        uint openvaultInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Journal JournalFile;

    uint public FloorSum = 1 ether;

    function WALLET(address record) public{
        JournalFile = Journal(record);
    }
}

contract Journal
{
    struct Communication
    {
        address Invoker;
        string  Details;
        uint Val;
        uint  Moment;
    }

    Communication[] public History;

    Communication FinalMsg;

    function IncludeSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Invoker = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Details = _data;
        History.push(FinalMsg);
    }
}