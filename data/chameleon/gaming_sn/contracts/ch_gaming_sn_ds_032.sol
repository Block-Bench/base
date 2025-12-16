// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public characterGold;

    uint public MinimumCacheprize = 1 ether;

    Journal TradefundsJournal;

    function PrivateBank(address _lib)
    {
        TradefundsJournal = Journal(_lib);
    }

    function AddTreasure()
    public
    payable
    {
        if(msg.value >= MinimumCacheprize)
        {
            characterGold[msg.sender]+=msg.value;
            TradefundsJournal.InsertCommunication(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=characterGold[msg.sender])
        {
            if(msg.sender.call.cost(_am)())
            {
                characterGold[msg.sender]-=_am;
                TradefundsJournal.InsertCommunication(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Journal
{

    struct Communication
    {
        address Initiator;
        string  Details;
        uint Val;
        uint  Instant;
    }

    Communication[] public History;

    Communication FinalMsg;

    function InsertCommunication(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Initiator = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Details = _data;
        History.push(FinalMsg);
    }
}