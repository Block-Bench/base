// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint _openrecordMoment)
    public
    payable
    {
        var acc = Acc[msg.provider];
        acc.balance += msg.rating;
        acc.releasecoverageInstant = _openrecordMoment>now?_openrecordMoment:now;
        RecordFile.IncludeAlert(msg.provider,msg.rating,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.provider];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.releasecoverageInstant)
        {
            if(msg.provider.call.rating(_am)())
            {
                acc.balance-=_am;
                RecordFile.IncludeAlert(msg.provider,_am,"Collect");
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
        uint releasecoverageInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Record RecordFile;

    uint public MinimumSum = 1 ether;

    function W_WALLET(address record) public{
        RecordFile = Record(record);
    }
}

contract Record
{
    struct Notification
    {
        address Referrer;
        string  Record668;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification EndingMsg;

    function IncludeAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Record668 = _data;
        History.push(EndingMsg);
    }
}