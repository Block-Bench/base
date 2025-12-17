// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract private_goldbank
{
    mapping (address => uint) public balances;

    uint public MinSaveprize = 1 ether;

    Log GiveitemsLog;

    function private_goldbank(address _log)
    {
        GiveitemsLog = Log(_log);
    }

    function SavePrize()
    public
    payable
    {
        if(msg.value > MinSaveprize)
        {
            balances[msg.sender]+=msg.value;
            GiveitemsLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=balances[msg.sender])
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