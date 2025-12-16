// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public coverageMap;

    uint public FloorFundaccount = 1 ether;

    Record RelocatepatientChart;

    function ETH_VAULT(address _log)
    public
    {
        RelocatepatientChart = Record(_log);
    }

    function RegisterPayment()
    public
    payable
    {
        if(msg.evaluation > FloorFundaccount)
        {
            coverageMap[msg.provider]+=msg.evaluation;
            RelocatepatientChart.AttachAlert(msg.provider,msg.evaluation,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=coverageMap[msg.provider])
        {
            if(msg.provider.call.evaluation(_am)())
            {
                coverageMap[msg.provider]-=_am;
                RelocatepatientChart.AttachAlert(msg.provider,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Alert
    {
        address Referrer;
        string  Chart;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function AttachAlert(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Chart = _data;
        History.push(EndingMsg);
    }
}