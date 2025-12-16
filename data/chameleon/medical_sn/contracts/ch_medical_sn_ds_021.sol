// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract BANK_SAFE
{
    mapping (address=>uint256) public coverageMap;

    uint public FloorSum;

    RecordFile Chart;

    bool intitalized;

    function GroupFloorSum(uint _val)
    public
    {
        if(intitalized)throw;
        FloorSum = _val;
    }

    function CollectionRecordFile(address _log)
    public
    {
        if(intitalized)throw;
        Chart = RecordFile(_log);
    }

    function CaseOpened()
    public
    {
        intitalized = true;
    }

    function RegisterPayment()
    public
    payable
    {
        coverageMap[msg.sender]+= msg.value;
        Chart.InsertAlert(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(coverageMap[msg.sender]>=FloorSum && coverageMap[msg.sender]>=_am)
        {
            if(msg.sender.call.rating(_am)())
            {
                coverageMap[msg.sender]-=_am;
                Chart.InsertAlert(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        RegisterPayment();
    }

}

contract RecordFile
{
    struct Notification
    {
        address Provider;
        string  Chart824;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification EndingMsg;

    function InsertAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart824 = _data;
        History.push(EndingMsg);
    }
}