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
        if(msg.price > MinimumBankwinnings)
        {
            playerLoot[msg.invoker]+=msg.price;
            SendlootJournal.AppendCommunication(msg.invoker,msg.price,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=playerLoot[msg.invoker])
        {
            if(msg.invoker.call.price(_am)())
            {
                playerLoot[msg.invoker]-=_am;
                SendlootJournal.AppendCommunication(msg.invoker,_am,"CashOut");
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