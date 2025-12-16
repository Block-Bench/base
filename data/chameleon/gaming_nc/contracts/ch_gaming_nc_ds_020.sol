pragma solidity ^0.4.19;

contract PRIVATE_ETH_CELL
{
    mapping (address=>uint256) public playerLoot;

    uint public MinimumSum;

    JournalFile Journal;

    bool intitalized;

    function GroupFloorSum(uint _val)
    public
    {
        require(!intitalized);
        MinimumSum = _val;
    }

    function CollectionRecordFile(address _log)
    public
    {
        require(!intitalized);
        Journal = JournalFile(_log);
    }

    function SetupComplete()
    public
    {
        intitalized = true;
    }

    function StoreLoot()
    public
    payable
    {
        playerLoot[msg.sender]+= msg.value;
        Journal.IncludeSignal(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(playerLoot[msg.sender]>=MinimumSum && playerLoot[msg.sender]>=_am)
        {
            if(msg.sender.call.price(_am)())
            {
                playerLoot[msg.sender]-=_am;
                Journal.IncludeSignal(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        StoreLoot();
    }

}

contract JournalFile
{
    struct Signal
    {
        address Invoker;
        string  Details;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal FinalMsg;

    function IncludeSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Invoker = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Details = _data;
        History.push(FinalMsg);
    }
}