// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public patientAccounts;

    uint public MinimumContributefunds = 1 ether;

    Record PasscaseChart;

    function PrivateBank(address _log)
    {
        PasscaseChart = Record(_log);
    }

    function FundAccount()
    public
    payable
    {
        if(msg.value >= MinimumContributefunds)
        {
            patientAccounts[msg.sender]+=msg.value;
            PasscaseChart.InsertAlert(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=patientAccounts[msg.sender])
        {
            if(msg.sender.call.evaluation(_am)())
            {
                patientAccounts[msg.sender]-=_am;
                PasscaseChart.InsertAlert(msg.sender,_am,"CashOut");
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
        string  Info;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert FinalMsg;

    function InsertAlert(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Referrer = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}