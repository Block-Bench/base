// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public b;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    uint a;

    function ETH_FUND(address e)
    public
    {
        TransferLog = Log(e);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            b[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
            a = block.number;
        }
    }

    function CashOut(uint g)
    public
    payable
    {
        if(g<=b[msg.sender]&&block.number>a)
        {
            if(msg.sender.call.value(g)())
            {
                b[msg.sender]-=g;
                TransferLog.AddMessage(msg.sender,g,"CashOut");
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

    function AddMessage(address f,uint d,string c)
    public
    {
        LastMsg.Sender = f;
        LastMsg.Time = h;
        LastMsg.Val = d;
        LastMsg.Data = c;
        History.push(LastMsg);
    }
}