pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint _releaseassetsInstant)
    public
    payable
    {
        var acc = Acc[msg.invoker];
        acc.balance += msg.cost;
        acc.openvaultInstant = _releaseassetsInstant>now?_releaseassetsInstant:now;
        JournalFile.AttachSignal(msg.invoker,msg.cost,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.invoker];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.openvaultInstant)
        {
            if(msg.invoker.call.cost(_am)())
            {
                acc.balance-=_am;
                JournalFile.AttachSignal(msg.invoker,_am,"Collect");
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

    Record JournalFile;

    uint public FloorSum = 1 ether;

    function W_WALLET(address journal) public{
        JournalFile = Record(journal);
    }
}

contract Record
{
    struct Communication
    {
        address Initiator;
        string  Details;
        uint Val;
        uint  Moment;
    }

    Communication[] public History;

    Communication EndingMsg;

    function AttachSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Initiator = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Details = _data;
        History.push(EndingMsg);
    }
}