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
        heroTreasure[msg.caster]+= msg.price;
        Record.AttachCommunication(msg.caster,msg.price,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(heroTreasure[msg.caster]>=FloorSum && heroTreasure[msg.caster]>=_am)
        {
            if(msg.caster.call.price(_am)())
            {
                heroTreasure[msg.caster]-=_am;
                Record.AttachCommunication(msg.caster,_am,"Collect");
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