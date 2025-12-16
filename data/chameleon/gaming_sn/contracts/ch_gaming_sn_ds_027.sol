// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract X_WALLET
{
    function Put(uint _releaseassetsMoment)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.releaseassetsInstant = _releaseassetsMoment>now?_releaseassetsMoment:now;
        RecordFile.InsertCommunication(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.sender];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.releaseassetsInstant)
        {
            if(msg.sender.call.cost(_am)())
            {
                acc.balance-=_am;
                RecordFile.InsertCommunication(msg.sender,_am,"Collect");
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
        uint releaseassetsInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Journal RecordFile;

    uint public MinimumSum = 1 ether;

    function X_WALLET(address journal) public{
        RecordFile = Journal(journal);
    }
}

contract Journal
{
    struct Signal
    {
        address Invoker;
        string  Details;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal EndingMsg;

    function InsertCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Invoker = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Details = _data;
        History.push(EndingMsg);
    }
}