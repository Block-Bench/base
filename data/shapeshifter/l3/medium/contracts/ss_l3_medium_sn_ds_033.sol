// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0xe3a4d1;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function ETH_VAULT(address _0x6fb392)
    public
    {
        TransferLog = Log(_0x6fb392);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0xe3a4d1[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xd74f52)
    public
    payable
    {
        if(_0xd74f52<=_0xe3a4d1[msg.sender])
        {
            if(msg.sender.call.value(_0xd74f52)())
            {
                _0xe3a4d1[msg.sender]-=_0xd74f52;
                TransferLog.AddMessage(msg.sender,_0xd74f52,"CashOut");
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

    function AddMessage(address _0x94bdde,uint _0x45950c,string _0x0f0262)
    public
    {
        LastMsg.Sender = _0x94bdde;
        LastMsg.Time = _0xe72eda;
        LastMsg.Val = _0x45950c;
        LastMsg.Data = _0x0f0262;
        History.push(LastMsg);
    }
}