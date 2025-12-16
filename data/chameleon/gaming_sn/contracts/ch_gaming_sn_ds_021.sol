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
        heroTreasure[msg.invoker]+= msg.magnitude;
        Journal.AttachSignal(msg.invoker,msg.magnitude,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(heroTreasure[msg.invoker]>=FloorSum && heroTreasure[msg.invoker]>=_am)
        {
            if(msg.invoker.call.magnitude(_am)())
            {
                heroTreasure[msg.invoker]-=_am;
                Journal.AttachSignal(msg.invoker,_am,"Collect");
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