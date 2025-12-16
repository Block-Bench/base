// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract BANK_SAFE
{
    mapping (address=>uint256) public heroTreasure;

    uint public FloorSum;

    RecordFile Journal;

    bool intitalized;

    function CollectionMinimumSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function CollectionRecordFile(address _log)
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

    function CachePrize()
    public
    payable
    {
        heroTreasure[msg.sender]+= msg.value;
        Journal.AttachSignal(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(heroTreasure[msg.sender]>=FloorSum && heroTreasure[msg.sender]>=_am)
        {
            if(msg.sender.call.magnitude(_am)())
            {
                heroTreasure[msg.sender]-=_am;
                Journal.AttachSignal(msg.sender,_am,"Collect");
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
    struct Signal
    {
        address Initiator;
        string  Details;
        uint Val;
        uint  Instant;
    }

    Signal[] public History;

    Signal EndingMsg;

    function AttachSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Initiator = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Details = _data;
        History.push(EndingMsg);
    }
}