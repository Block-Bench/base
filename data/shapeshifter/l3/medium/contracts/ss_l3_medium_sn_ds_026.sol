// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0x9b7f03;

    Log TransferLog;

    uint public MinDeposit = 1 ether;

    function ETH_VAULT(address _0x79227b)
    public
    {
        TransferLog = Log(_0x79227b);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x9b7f03[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x9c32b5)
    public
    payable
    {
        if(_0x9c32b5<=_0x9b7f03[msg.sender])
        {
            if(msg.sender.call.value(_0x9c32b5)())
            {
                _0x9b7f03[msg.sender]-=_0x9c32b5;
                TransferLog.AddMessage(msg.sender,_0x9c32b5,"CashOut");
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

    function AddMessage(address _0x56e26b,uint _0xe8a9e3,string _0xea90ee)
    public
    {
        LastMsg.Sender = _0x56e26b;
        LastMsg.Time = _0xd2814f;
        LastMsg.Val = _0xe8a9e3;
        LastMsg.Data = _0xea90ee;
        History.push(LastMsg);
    }
}