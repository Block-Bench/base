// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract eth_tipvault
{
    mapping (address => uint) public balances;

    Log SendtipLog;

    uint public MinContribute = 1 ether;

    function eth_tipvault(address _log)
    public
    {
        SendtipLog = Log(_log);
    }

    function Contribute()
    public
    payable
    {
        if(msg.value > MinContribute)
        {
            balances[msg.sender]+=msg.value;
            SendtipLog.AddMessage(msg.sender,msg.value,"Deposit");
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
                SendtipLog.AddMessage(msg.sender,_am,"CashOut");
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