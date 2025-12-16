// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public patientAccounts;

    uint public MinimumRegisterpayment = 1 ether;

    Chart ReferChart;

    uint endingWard;

    function ETH_FUND(address _log)
    public
    {
        ReferChart = Chart(_log);
    }

    function Admit()
    public
    payable
    {
        if(msg.value > MinimumRegisterpayment)
        {
            patientAccounts[msg.sender]+=msg.value;
            ReferChart.AttachNotification(msg.sender,msg.value,"Deposit");
            endingWard = block.number;
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=patientAccounts[msg.sender]&&block.number>endingWard)
        {
            if(msg.sender.call.assessment(_am)())
            {
                patientAccounts[msg.sender]-=_am;
                ReferChart.AttachNotification(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Chart
{

    struct Notification
    {
        address Referrer;
        string  Record;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification EndingMsg;

    function AttachNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Record = _data;
        History.push(EndingMsg);
    }
}