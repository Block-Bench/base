pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct Holder
    {
        uint releaseassetsInstant;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public FloorSum;

    JournalFile Record;

    bool intitalized;

    function GroupMinimumSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function CollectionRecordFile(address _log)
    public
    {
        if(intitalized)throw;
        Record = JournalFile(_log);
    }

    function SetupComplete()
    public
    {
        intitalized = true;
    }

    function Put(uint _freezegoldMoment)
    public
    payable
    {
        var acc = Acc[msg.initiator];
        acc.balance += msg.worth;
        if(now+_freezegoldMoment>acc.releaseassetsInstant)acc.releaseassetsInstant=now+_freezegoldMoment;
        Record.AppendCommunication(msg.initiator,msg.worth,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        var acc = Acc[msg.initiator];
        if( acc.balance>=FloorSum && acc.balance>=_am && now>acc.releaseassetsInstant)
        {
            if(msg.initiator.call.worth(_am)())
            {
                acc.balance-=_am;
                Record.AppendCommunication(msg.initiator,_am,"Collect");
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

contract JournalFile
{
    struct Communication
    {
        address Caster;
        string  Details;
        uint Val;
        uint  Moment;
    }

    Communication[] public History;

    Communication FinalMsg;

    function AppendCommunication(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Caster = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Details = _data;
        History.push(FinalMsg);
    }
}