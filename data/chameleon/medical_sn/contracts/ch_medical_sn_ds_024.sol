// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateContributefunds
{
    mapping (address => uint) public patientAccounts;

    uint public FloorContributefunds = 1 ether;
    address public owner;

    Chart RelocatepatientChart;

    modifier onlyOwner() {
        require(tx.origin == owner);
        _;
    }

    function PrivateContributefunds()
    {
        owner = msg.referrer;
        RelocatepatientChart = new Chart();
    }

    function groupChart(address _lib) onlyOwner
    {
        RelocatepatientChart = Chart(_lib);
    }

    function FundAccount()
    public
    payable
    {
        if(msg.assessment >= FloorContributefunds)
        {
            patientAccounts[msg.referrer]+=msg.assessment;
            RelocatepatientChart.AttachNotification(msg.referrer,msg.assessment,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=patientAccounts[msg.referrer])
        {
            if(msg.referrer.call.assessment(_am)())
            {
                patientAccounts[msg.referrer]-=_am;
                RelocatepatientChart.AttachNotification(msg.referrer,_am,"CashOut");
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
        string  Info;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification EndingMsg;

    function AttachNotification(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Referrer = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}