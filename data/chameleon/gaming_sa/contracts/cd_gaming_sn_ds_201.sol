// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract private_goldbank
{
    mapping (address => uint) public balances;

    uint public MinStashitems = 1 ether;

    Log SendgoldLog;

    function private_goldbank(address _log)
    {
        SendgoldLog = Log(_log);
    }

    function StashItems()
    public
    payable
    {
        if(msg.value >= MinStashitems)
        {
            balances[msg.sender]+=msg.value;
            SendgoldLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=balances[msg.sender])
        {

            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                SendgoldLog.AddMessage(msg.sender,_am,"CashOut");
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