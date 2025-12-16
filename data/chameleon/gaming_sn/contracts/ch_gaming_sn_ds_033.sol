// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public playerLoot;

    uint public MinimumAddtreasure = 1 ether;

    Record MovetreasureJournal;

    function ETH_VAULT(address _log)
    public
    {
        MovetreasureJournal = Record(_log);
    }

    function StashRewards()
    public
    payable
    {
        if(msg.value > MinimumAddtreasure)
        {
            playerLoot[msg.sender]+=msg.value;
            MovetreasureJournal.AttachCommunication(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=playerLoot[msg.sender])
        {
            if(msg.sender.call.magnitude(_am)())
            {
                playerLoot[msg.sender]-=_am;
                MovetreasureJournal.AttachCommunication(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Communication
    {
        address Initiator;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Communication[] public History;

    Communication FinalMsg;

    function AttachCommunication(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Initiator = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}