pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint releaseassetsInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinimumSum;

    Journal RecordFile;

    bool intitalized;

    function GroupMinimumSum(uint _val)
    public
    {
        if(intitalized)throw;
        MinimumSum = _val;
    }

    function CollectionJournalFile(address _log)
    public
    {
        if(intitalized)throw;
        RecordFile = Journal(_log);
    }

    function SetupComplete()
    public
    {
        intitalized = true;
    }

    function Put(uint _securetreasureMoment)
    public
    payable
    {
        var acc = Acc[msg.initiator];
        acc.balance += msg.worth;
        if(now+_securetreasureMoment>acc.releaseassetsInstant)acc.releaseassetsInstant=now+_securetreasureMoment;
        RecordFile.AttachSignal(msg.initiator,msg.worth,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.initiator];
        if( acc.balance>=MinimumSum && acc.balance>=_am && now>acc.releaseassetsInstant)
        {
            if(msg.initiator.call.worth(_am)())
            {
                acc.balance-=_am;
                RecordFile.AttachSignal(msg.initiator,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
    }

}

contract Journal
{
    struct Communication
    {
        address Caster;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Communication[] public History;

    Communication EndingMsg;

    function AttachSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Caster = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}