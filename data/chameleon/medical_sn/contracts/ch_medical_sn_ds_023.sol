// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _openrecordInstant)
    public
    payable
    {
        var acc = Acc[msg.provider];
        acc.balance += msg.assessment;
        acc.openrecordInstant = _openrecordInstant>now?_openrecordInstant:now;
        ChartFile.InsertNotification(msg.provider,msg.assessment,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.provider];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.openrecordInstant)
        {
            if(msg.provider.call.assessment(_am)())
            {
                acc.balance-=_am;
                ChartFile.InsertNotification(msg.provider,_am,"Collect");
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

    uint public MinimumSum = 2 ether;

    function U_BANK(address chart) public{
        ChartFile = Record(chart);
    }
}

contract Record
{
    struct Notification
    {
        address Provider;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification EndingMsg;

    function InsertNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}