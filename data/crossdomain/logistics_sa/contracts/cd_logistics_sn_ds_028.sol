// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract eth_freightfund
{
    mapping (address => uint) public balances;

    uint public MinWarehouseitems = 1 ether;

    Log RelocatecargoLog;

    uint lastBlock;

    function eth_freightfund(address _log)
    public
    {
        RelocatecargoLog = Log(_log);
    }

    function WarehouseItems()
    public
    payable
    {
        if(msg.value > MinWarehouseitems)
        {
            balances[msg.sender]+=msg.value;
            RelocatecargoLog.AddMessage(msg.sender,msg.value,"Deposit");
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
                RelocatecargoLog.AddMessage(msg.sender,_am,"CashOut");
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