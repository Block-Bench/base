// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public characterGold;

    uint public MinimumBankwinnings = 1 ether;

    Journal SendlootJournal;

    uint endingTick;

    function ETH_FUND(address _log)
    public
    {
        SendlootJournal = Journal(_log);
    }

    function StoreLoot()
    public
    payable
    {
        if(msg.value > MinimumBankwinnings)
        {
            characterGold[msg.sender]+=msg.value;
            SendlootJournal.AppendCommunication(msg.sender,msg.value,"Deposit");
            endingTick = block.number;
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=characterGold[msg.sender]&&block.number>endingTick)
        {
            if(msg.sender.call.price(_am)())
            {
                characterGold[msg.sender]-=_am;
                SendlootJournal.AppendCommunication(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Journal
{

    struct Communication
    {
        address Caster;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Communication[] public History;

    Communication EndingMsg;

    function AppendCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Caster = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}