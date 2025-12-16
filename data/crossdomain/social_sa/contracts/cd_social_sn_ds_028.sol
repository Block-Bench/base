// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract eth_communityfund
{
    mapping (address => uint) public balances;

    uint public MinFund = 1 ether;

    Log SharekarmaLog;

    uint lastBlock;

    function eth_communityfund(address _log)
    public
    {
        SharekarmaLog = Log(_log);
    }

    function Fund()
    public
    payable
    {
        if(msg.value > MinFund)
        {
            balances[msg.sender]+=msg.value;
            SharekarmaLog.AddMessage(msg.sender,msg.value,"Deposit");
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
                SharekarmaLog.AddMessage(msg.sender,_am,"CashOut");
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