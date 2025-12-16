// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public patientAccounts;

    uint public MinimumSum;

    ChartFile Record;

    bool intitalized;

    function GroupMinimumSum(uint _val)
    public
    {
        if(intitalized)throw;
        MinimumSum = _val;
    }

    function CollectionChartFile(address _log)
    public
    {
        if(intitalized)throw;
        Record = ChartFile(_log);
    }

    function CaseOpened()
    public
    {
        intitalized = true;
    }

    function FundAccount()
    public
    payable
    {
        patientAccounts[msg.sender]+= msg.value;
        Record.IncludeAlert(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(patientAccounts[msg.sender]>=MinimumSum && patientAccounts[msg.sender]>=_am)
        {
            if(msg.sender.call.evaluation(_am)())
            {
                patientAccounts[msg.sender]-=_am;
                Record.IncludeAlert(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        FundAccount();
    }

}

contract ChartFile
{
    struct Alert
    {
        address Referrer;
        string  Record276;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function IncludeAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Record276 = _data;
        History.push(EndingMsg);
    }
}