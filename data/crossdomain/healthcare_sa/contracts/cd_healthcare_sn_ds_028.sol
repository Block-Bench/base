// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract eth_treatmentfund
{
    mapping (address => uint) public balances;

    uint public MinDepositbenefit = 1 ether;

    Log MovecoverageLog;

    uint lastBlock;

    function eth_treatmentfund(address _log)
    public
    {
        MovecoverageLog = Log(_log);
    }

    function DepositBenefit()
    public
    payable
    {
        if(msg.value > MinDepositbenefit)
        {
            balances[msg.sender]+=msg.value;
            MovecoverageLog.AddMessage(msg.sender,msg.value,"Deposit");
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
                MovecoverageLog.AddMessage(msg.sender,_am,"CashOut");
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