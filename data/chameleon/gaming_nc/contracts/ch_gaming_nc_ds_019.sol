*/

pragma solidity ^0.4.19;

contract accural_bankwinnings
{
    mapping (address=>uint256) public heroTreasure;

    uint public MinimumSum = 1 ether;

    RecordFile Record = RecordFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool intitalized;

    function CollectionFloorSum(uint _val)
    public
    {
        if(intitalized)revert();
        MinimumSum = _val;
    }

    function CollectionRecordFile(address _log)
    public
    {
        if(intitalized)revert();
        Record = RecordFile(_log);
    }

    function SetupComplete()
    public
    {
        intitalized = true;
    }

    function CachePrize()
    public
    payable
    {
        heroTreasure[msg.caster]+= msg.worth;
        Record.AttachCommunication(msg.caster,msg.worth,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(heroTreasure[msg.caster]>=MinimumSum && heroTreasure[msg.caster]>=_am)
        {
            if(msg.caster.call.worth(_am)())
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
        CachePrize();
    }

}

contract RecordFile
{
    struct Communication
    {
        address Invoker;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Communication[] public History;

    Communication EndingMsg;

    function AttachCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Invoker = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}