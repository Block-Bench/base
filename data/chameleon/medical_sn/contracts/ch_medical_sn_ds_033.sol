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
        if(msg.value > FloorFundaccount)
        {
            coverageMap[msg.sender]+=msg.value;
            RelocatepatientChart.AttachAlert(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=coverageMap[msg.sender])
        {
            if(msg.sender.call.evaluation(_am)())
            {
                coverageMap[msg.sender]-=_am;
                RelocatepatientChart.AttachAlert(msg.sender,_am,"CashOut");
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