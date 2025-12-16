// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public userRewards;

    uint public MinimumStashrewards = 1 ether;

    Record TradefundsJournal;

    function Private_Bank(address _log)
    {
        TradefundsJournal = Record(_log);
    }

    function CachePrize()
    public
    payable
    {
        if(msg.value > MinimumStashrewards)
        {
            userRewards[msg.sender]+=msg.value;
            TradefundsJournal.AppendCommunication(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=userRewards[msg.sender])
        {
            if(msg.sender.call.worth(_am)())
            {
                userRewards[msg.sender]-=_am;
                TradefundsJournal.AppendCommunication(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Signal
    {
        address Initiator;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal EndingMsg;

    function AppendCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Initiator = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}