// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public _0x9fd6bd;

    Log TransferLog;

    uint public MinDeposit = 1 ether;

    function ETH_VAULT(address _0x4b2dbe)
    public
    {
        TransferLog = Log(_0x4b2dbe);
    }

    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            _0x9fd6bd[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0x8b8c81)
    public
    payable
    {
        if(_0x8b8c81<=_0x9fd6bd[msg.sender])
        {
            if(msg.sender.call.value(_0x8b8c81)())
            {
                _0x9fd6bd[msg.sender]-=_0x8b8c81;
                TransferLog.AddMessage(msg.sender,_0x8b8c81,"CashOut");
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

    function AddMessage(address _0x71e6b0,uint _0xe18e78,string _0x355b14)
    public
    {
        LastMsg.Sender = _0x71e6b0;
        LastMsg.Time = _0x1dd968;
        LastMsg.Val = _0xe18e78;
        LastMsg.Data = _0x355b14;
        History.push(LastMsg);
    }
}