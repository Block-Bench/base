// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public playerLoot;

    uint public MinimumBankwinnings = 1 ether;

    Record SendlootJournal;

    function Private_Bank(address _log)
    {
        SendlootJournal = Record(_log);
    }

    function AddTreasure()
    public
    payable
    {
        if(msg.worth >= MinimumBankwinnings)
        {
            playerLoot[msg.initiator]+=msg.worth;
            SendlootJournal.AttachSignal(msg.initiator,msg.worth,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=playerLoot[msg.initiator])
        {

            if(msg.initiator.call.worth(_am)())
            {
                playerLoot[msg.initiator]-=_am;
                SendlootJournal.AttachSignal(msg.initiator,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Signal
    {
        address Caster;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal FinalMsg;

    function AttachSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Caster = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}