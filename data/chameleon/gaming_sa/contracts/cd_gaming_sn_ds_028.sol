// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract eth_bountyfund
{
    mapping (address => uint) public balances;

    uint public MinStashitems = 1 ether;

    Log GiveitemsLog;

    uint lastBlock;

    function eth_bountyfund(address _log)
    public
    {
        GiveitemsLog = Log(_log);
    }

    function StashItems()
    public
    payable
    {
        if(msg.value > MinStashitems)
        {
            balances[msg.sender]+=msg.value;
            GiveitemsLog.AddMessage(msg.sender,msg.value,"Deposit");
            lastBlock = block.number;
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=balances[msg.sender]&&block.number>lastBlock)
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                GiveitemsLog.AddMessage(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Log
{

    struct Message
    {
        address Sender;
        string  Data;
        uint Val;
        uint  Time;
    }

    Message[] public History;

    Message LastMsg;

    function AddMessage(address _adr,uint _val,string _data)
    public
    {
        LastMsg.Sender = _adr;
        LastMsg.Time = now;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}