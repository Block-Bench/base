pragma solidity ^0.4.25;

contract WALLET
{
    function Put(uint _openvaultInstant)
    public
    payable
    {
        var acc = Acc[msg.caster];
        acc.balance += msg.magnitude;
        acc.releaseassetsInstant = _openvaultInstant>now?_openvaultInstant:now;
        RecordFile.AttachCommunication(msg.caster,msg.magnitude,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.caster];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.releaseassetsInstant)
        {
            if(msg.caster.call.magnitude(_am)())
            {
                acc.balance-=_am;
                RecordFile.AttachCommunication(msg.caster,_am,"Collect");
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

    Record RecordFile;

    uint public FloorSum = 1 ether;

    function WALLET(address record) public{
        RecordFile = Record(record);
    }
}

contract Record
{
    struct Communication
    {
        address Initiator;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Communication[] public History;

    Communication EndingMsg;

    function AttachCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Initiator = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}