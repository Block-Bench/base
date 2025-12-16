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
        if(msg.magnitude > MinimumAddtreasure)
        {
            playerLoot[msg.invoker]+=msg.magnitude;
            MovetreasureJournal.AttachCommunication(msg.invoker,msg.magnitude,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=playerLoot[msg.invoker])
        {
            if(msg.invoker.call.magnitude(_am)())
            {
                playerLoot[msg.invoker]-=_am;
                MovetreasureJournal.AttachCommunication(msg.invoker,_am,"CashOut");
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