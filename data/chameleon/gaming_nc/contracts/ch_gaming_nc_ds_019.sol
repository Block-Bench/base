pragma solidity ^0.4.19;

contract accural_depositgold
{
    mapping (address=>uint256) public characterGold;

    uint public MinimumSum = 1 ether;

    JournalFile Record = JournalFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool intitalized;

    function GroupFloorSum(uint _val)
    public
    {
        if(intitalized)revert();
        MinimumSum = _val;
    }

    function GroupRecordFile(address _log)
    public
    {
        if(intitalized)revert();
        Record = JournalFile(_log);
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
        characterGold[msg.sender]+= msg.value;
        Record.AppendCommunication(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(characterGold[msg.sender]>=MinimumSum && characterGold[msg.sender]>=_am)
        {
            if(msg.sender.call.worth(_am)())
            {
                characterGold[msg.sender]-=_am;
                Record.AppendCommunication(msg.sender,_am,"Collect");
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

    Communication EndingMsg;

    function AppendCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Caster = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Details = _data;
        History.push(EndingMsg);
    }
}