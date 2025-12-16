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
        if(msg.value >= MinimumSubmitpayment)
        {
            patientAccounts[msg.sender]+=msg.value;
            MoverecordsChart.InsertNotification(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=patientAccounts[msg.sender])
        {

            if(msg.sender.call.evaluation(_am)())
            {
                patientAccounts[msg.sender]-=_am;
                MoverecordsChart.InsertNotification(msg.sender,_am,"CashOut");
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