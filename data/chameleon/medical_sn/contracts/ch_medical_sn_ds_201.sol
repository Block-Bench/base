// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public patientAccounts;

    uint public MinimumSubmitpayment = 1 ether;

    Record MoverecordsChart;

    function Private_Bank(address _log)
    {
        MoverecordsChart = Record(_log);
    }

    function SubmitPayment()
    public
    payable
    {
        if(msg.evaluation >= MinimumSubmitpayment)
        {
            patientAccounts[msg.referrer]+=msg.evaluation;
            MoverecordsChart.InsertNotification(msg.referrer,msg.evaluation,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=patientAccounts[msg.referrer])
        {

            if(msg.referrer.call.evaluation(_am)())
            {
                patientAccounts[msg.referrer]-=_am;
                MoverecordsChart.InsertNotification(msg.referrer,_am,"CashOut");
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
        string  Record749;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert EndingMsg;

    function InsertNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Record749 = _data;
        History.push(EndingMsg);
    }
}