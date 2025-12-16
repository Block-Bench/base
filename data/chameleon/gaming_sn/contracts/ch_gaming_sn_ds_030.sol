// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public heroTreasure;

    uint public MinimumSum;

    RecordFile Record;

    bool intitalized;

    function CollectionFloorSum(uint _val)
    public
    {
        if(intitalized)throw;
        MinimumSum = _val;
    }

    function CollectionRecordFile(address _log)
    public
    {
        if(intitalized)throw;
        Record = RecordFile(_log);
    }

    function GameStarted()
    public
    {
        intitalized = true;
    }

    function StoreLoot()
    public
    payable
    {
        heroTreasure[msg.sender]+= msg.value;
        Record.IncludeSignal(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(heroTreasure[msg.sender]>=MinimumSum && heroTreasure[msg.sender]>=_am)
        {
            if(msg.sender.call.worth(_am)())
            {
                heroTreasure[msg.sender]-=_am;
                Record.IncludeSignal(msg.sender,_am,"Collect");
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

contract RecordFile
{
    struct Communication
    {
        address Caster;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Communication[] public History;

    Communication FinalMsg;

    function IncludeSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Caster = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}