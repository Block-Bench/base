// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PRIVATE_ETH_CELL
{
    mapping (address=>uint256) public characterGold;

    uint public FloorSum;

    JournalFile Journal;

    bool intitalized;

    function CollectionMinimumSum(uint _val)
    public
    {
        require(!intitalized);
        FloorSum = _val;
    }

    function GroupRecordFile(address _log)
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

    function CachePrize()
    public
    payable
    {
        characterGold[msg.sender]+= msg.value;
        Journal.AttachSignal(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(characterGold[msg.sender]>=FloorSum && characterGold[msg.sender]>=_am)
        {
            if(msg.sender.call.price(_am)())
            {
                characterGold[msg.sender]-=_am;
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

contract JournalFile
{
    struct Signal
    {
        address Initiator;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal EndingMsg;

    function AttachSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Initiator = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}