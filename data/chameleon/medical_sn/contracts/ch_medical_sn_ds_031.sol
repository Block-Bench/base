// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public patientAccounts;

    uint public FloorSubmitpayment = 1 ether;

    Record RelocatepatientChart;

    function Private_Bank(address _log)
    {
        RelocatepatientChart = Record(_log);
    }

    function ContributeFunds()
    public
    payable
    {
        if(msg.value > FloorSubmitpayment)
        {
            patientAccounts[msg.sender]+=msg.value;
            RelocatepatientChart.AppendAlert(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=patientAccounts[msg.sender])
        {
            if(msg.sender.call.assessment(_am)())
            {
                patientAccounts[msg.sender]-=_am;
                RelocatepatientChart.AppendAlert(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Notification
    {
        address Provider;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification FinalMsg;

    function AppendAlert(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Provider = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}