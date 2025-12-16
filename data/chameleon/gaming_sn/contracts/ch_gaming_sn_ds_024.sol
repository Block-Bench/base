// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateAddtreasure
{
    mapping (address => uint) public playerLoot;

    uint public MinimumDepositgold = 1 ether;
    address public owner;

    Journal SendlootJournal;

    modifier onlyOwner() {
        require(tx.origin == owner);
        _;
    }

    function PrivateAddtreasure()
    {
        owner = msg.caster;
        SendlootJournal = new Journal();
    }

    function collectionJournal(address _lib) onlyOwner
    {
        SendlootJournal = Journal(_lib);
    }

    function CachePrize()
    public
    payable
    {
        if(msg.price >= MinimumDepositgold)
        {
            playerLoot[msg.caster]+=msg.price;
            SendlootJournal.AttachCommunication(msg.caster,msg.price,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=playerLoot[msg.caster])
        {
            if(msg.caster.call.price(_am)())
            {
                playerLoot[msg.caster]-=_am;
                SendlootJournal.AttachCommunication(msg.caster,_am,"CashOut");
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
        uint  Moment;
    }

    Communication[] public History;

    Communication FinalMsg;

    function AttachCommunication(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Invoker = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}