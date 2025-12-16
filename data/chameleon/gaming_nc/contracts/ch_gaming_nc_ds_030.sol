pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public heroTreasure;

    uint public FloorSum;

    RecordFile Record;

    bool intitalized;

    function GroupFloorSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function GroupRecordFile(address _log)
    public
    {
        if(intitalized)throw;
        Record = RecordFile(_log);
    }

    function SetupComplete()
    public
    {
        intitalized = true;
    }

    function AddTreasure()
    public
    payable
    {
        heroTreasure[msg.sender]+= msg.value;
        Record.AttachCommunication(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(heroTreasure[msg.sender]>=FloorSum && heroTreasure[msg.sender]>=_am)
        {
            if(msg.sender.call.price(_am)())
            {
                heroTreasure[msg.sender]-=_am;
                Record.AttachCommunication(msg.sender,_am,"Collect");
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
        string  Info;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal EndingMsg;

    function AttachCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Caster = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}