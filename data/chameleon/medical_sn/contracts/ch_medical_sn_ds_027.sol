// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract X_WALLET
{
    function Put(uint _releasecoverageMoment)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.openrecordInstant = _releasecoverageMoment>now?_releasecoverageMoment:now;
        ChartFile.AttachAlert(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.openrecordInstant)
        {
            if(msg.sender.call.evaluation(_am)())
            {
                acc.balance-=_am;
                ChartFile.AttachAlert(msg.sender,_am,"Collect");
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

    Record ChartFile;

    uint public FloorSum = 1 ether;

    function X_WALLET(address chart) public{
        ChartFile = Record(chart);
    }
}

contract Record
{
    struct Notification
    {
        address Referrer;
        string  Chart;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification EndingMsg;

    function AttachAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart = _data;
        History.push(EndingMsg);
    }
}