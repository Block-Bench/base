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
        if(msg.worth > MinimumStashrewards)
        {
            userRewards[msg.caster]+=msg.worth;
            TradefundsJournal.AppendCommunication(msg.caster,msg.worth,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=userRewards[msg.caster])
        {
            if(msg.caster.call.worth(_am)())
            {
                userRewards[msg.caster]-=_am;
                TradefundsJournal.AppendCommunication(msg.caster,_am,"CashOut");
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