// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PRIVATE_ETH_CELL
{
    mapping (address=>uint256) public patientAccounts;

    uint public MinimumSum;

    RecordFile Record;

    bool intitalized;

    function CollectionMinimumSum(uint _val)
    public
    {
        require(!intitalized);
        MinimumSum = _val;
    }

    function GroupChartFile(address _log)
    public
    {
        require(!intitalized);
        Record = RecordFile(_log);
    }

    function CaseOpened()
    public
    {
        intitalized = true;
    }

    function Admit()
    public
    payable
    {
        patientAccounts[msg.referrer]+= msg.evaluation;
        Record.IncludeNotification(msg.referrer,msg.evaluation,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(patientAccounts[msg.referrer]>=MinimumSum && patientAccounts[msg.referrer]>=_am)
        {
            if(msg.referrer.call.evaluation(_am)())
            {
                patientAccounts[msg.referrer]-=_am;
                Record.IncludeNotification(msg.referrer,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Admit();
    }

}

contract RecordFile
{
    struct Alert
    {
        address Provider;
        string  Record350;
        uint Val;
        uint  Moment;
    }

    Alert[] public History;

    Alert EndingMsg;

    function IncludeNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Provider = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Record350 = _data;
        History.push(EndingMsg);
    }
}