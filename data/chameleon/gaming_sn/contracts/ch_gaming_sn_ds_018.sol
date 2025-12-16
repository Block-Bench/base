// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public userRewards;

    uint public FloorDepositgold = 1 ether;

    Journal TradefundsJournal;

    function PrivateBank(address _log)
    {
        TradefundsJournal = Journal(_log);
    }

    function CachePrize()
    public
    payable
    {
        if(msg.cost >= FloorDepositgold)
        {
            userRewards[msg.initiator]+=msg.cost;
            TradefundsJournal.InsertSignal(msg.initiator,msg.cost,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=userRewards[msg.initiator])
        {
            if(msg.initiator.call.cost(_am)())
            {
                userRewards[msg.initiator]-=_am;
                TradefundsJournal.InsertSignal(msg.initiator,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Journal
{

    struct Communication
    {
        address Invoker;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Communication[] public History;

    Communication EndingMsg;

    function InsertSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Invoker = _adr;
        EndingMsg.Instant = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}