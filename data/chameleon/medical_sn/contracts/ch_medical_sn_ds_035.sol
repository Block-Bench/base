// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract HealthWallet
{
    function Put(uint _openrecordInstant)
    public
    payable
    {
        var acc = Acc[msg.provider];
        acc.balance += msg.rating;
        acc.openrecordInstant = _openrecordInstant>now?_openrecordInstant:now;
        RecordFile.AppendAlert(msg.provider,msg.rating,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.provider];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.openrecordInstant)
        {
            if(msg.provider.call.rating(_am)())
            {
                acc.balance-=_am;
                RecordFile.AppendAlert(msg.provider,_am,"Collect");
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
        uint openrecordInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Record RecordFile;

    uint public FloorSum = 1 ether;

    function HealthWallet(address record) public{
        RecordFile = Record(record);
    }
}

contract Record
{
    struct Alert
    {
        address Referrer;
        string  Chart;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert FinalMsg;

    function AppendAlert(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Referrer = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Chart = _data;
        History.push(FinalMsg);
    }
}