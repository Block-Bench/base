pragma solidity ^0.4.19;

contract BANK_SAFE
{
    mapping (address=>uint256) public userRewards;

    uint public FloorSum;

    RecordFile Journal;

    bool intitalized;

    function GroupMinimumSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function CollectionJournalFile(address _log)
    public
    {
        if(intitalized)throw;
        Journal = RecordFile(_log);
    }

    function GameStarted()
    public
    {
        intitalized = true;
    }

    function BankWinnings()
    public
    payable
    {
        userRewards[msg.caster]+= msg.cost;
        Journal.AttachSignal(msg.caster,msg.cost,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(userRewards[msg.caster]>=FloorSum && userRewards[msg.caster]>=_am)
        {
            if(msg.caster.call.cost(_am)())
            {
                userRewards[msg.caster]-=_am;
                Journal.AttachSignal(msg.caster,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        BankWinnings();
    }

}

contract RecordFile
{
    struct Signal
    {
        address Initiator;
        string  Details;
        uint Val;
        uint  Instant;
    }

    Signal[] public History;

    Signal FinalMsg;

    function AttachSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Initiator = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Details = _data;
        History.push(FinalMsg);
    }
}