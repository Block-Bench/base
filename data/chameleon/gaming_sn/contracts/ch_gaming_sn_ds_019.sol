pragma solidity ^0.4.19;

contract accural_storeloot
{
    mapping (address=>uint256) public userRewards;

    uint public MinimumSum = 1 ether;

    RecordFile Journal = RecordFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool intitalized;

    function GroupFloorSum(uint _val)
    public
    {
        if(intitalized)revert();
        MinimumSum = _val;
    }

    function CollectionJournalFile(address _log)
    public
    {
        if(intitalized)revert();
        Journal = RecordFile(_log);
    }

    function GameStarted()
    public
    {
        intitalized = true;
    }

    function AddTreasure()
    public
    payable
    {
        userRewards[msg.sender]+= msg.value;
        Journal.InsertCommunication(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(userRewards[msg.sender]>=MinimumSum && userRewards[msg.sender]>=_am)
        {
            if(msg.sender.call.price(_am)())
            {
                userRewards[msg.sender]-=_am;
                Journal.InsertCommunication(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        AddTreasure();
    }

}

contract RecordFile
{
    struct Signal
    {
        address Caster;
        string  Details;
        uint Val;
        uint  Instant;
    }

    Signal[] public History;

    Signal EndingMsg;

    function InsertCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Caster = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Details = _data;
        History.push(EndingMsg);
    }
}
