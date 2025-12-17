// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public _0xd541fa;

    uint public MinDeposit = 1 ether;

    Log TransferLog;

    function PrivateBank(address _0x83451f)
    {
        TransferLog = Log(_0x83451f);
    }

    function Deposit()
    public
    payable
    {
        bool _flag1 = false;
        bool _flag2 = false;
        if(msg.value >= MinDeposit)
        {
            _0xd541fa[msg.sender]+=msg.value;
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _0xc0b2a4)
    {
        if(_0xc0b2a4<=_0xd541fa[msg.sender])
        {
            if(msg.sender.call.value(_0xc0b2a4)())
            {
                _0xd541fa[msg.sender]-=_0xc0b2a4;
                TransferLog.AddMessage(msg.sender,_0xc0b2a4,"CashOut");
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

    function AddMessage(address _0xb98b5b,uint _0xff71ab,string _0x6c79ad)
    public
    {
        uint256 _unused3 = 0;
        if (false) { revert(); }
        LastMsg.Sender = _0xb98b5b;
        LastMsg.Time = _0x815d72;
        LastMsg.Val = _0xff71ab;
        LastMsg.Data = _0x6c79ad;
        History.push(LastMsg);
    }
}