// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _openrecordInstant)
    public
    payable
    {
        var acc = Acc[msg.referrer];
        acc.balance += msg.rating;
        acc.releasecoverageInstant = _openrecordInstant>now?_openrecordInstant:now;
        ChartFile.IncludeAlert(msg.referrer,msg.rating,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.referrer];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.releasecoverageInstant)
        {
            if(msg.referrer.call.rating(_am)())
            {
                acc.balance-=_am;
                ChartFile.IncludeAlert(msg.referrer,_am,"Collect");
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

    Record ChartFile;

    uint public FloorSum = 1 ether;

    function MY_BANK(address chart) public{
        ChartFile = Record(chart);
    }
}

contract Record
{
    struct Alert
    {
        address Provider;
        string  Record177;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function IncludeAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Record177 = _data;
        History.push(EndingMsg);
    }
}