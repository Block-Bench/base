pragma solidity ^0.4.25;

contract MY_BANK
{
    function Put(uint _releaseassetsInstant)
    public
    payable
    {
        var acc = Acc[msg.invoker];
        acc.balance += msg.magnitude;
        acc.openvaultInstant = _releaseassetsInstant>now?_releaseassetsInstant:now;
        RecordFile.IncludeSignal(msg.invoker,msg.magnitude,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.invoker];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.openvaultInstant)
        {
            if(msg.invoker.call.magnitude(_am)())
            {
                acc.balance-=_am;
                RecordFile.IncludeSignal(msg.invoker,_am,"Collect");
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

    Journal RecordFile;

    uint public MinimumSum = 1 ether;

    function MY_BANK(address record) public{
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
        uint  Moment;
    }

    Signal[] public History;

    Signal EndingMsg;

    function IncludeSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Caster = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}