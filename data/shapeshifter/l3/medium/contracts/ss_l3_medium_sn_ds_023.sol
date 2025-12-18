// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract U_BANK
{
    function Put(uint _0xe9dfca)
    public
    payable
    {
        var _0x9660f1 = Acc[msg.sender];
        _0x9660f1.balance += msg.value;
        _0x9660f1._0xbc406f = _0xe9dfca>_0x91806f?_0xe9dfca:_0x91806f;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x0848bc)
    public
    payable
    {
        var _0x9660f1 = Acc[msg.sender];
        if( _0x9660f1.balance>=MinSum && _0x9660f1.balance>=_0x0848bc && _0x91806f>_0x9660f1._0xbc406f)
        {
            if(msg.sender.call.value(_0x0848bc)())
            {
                _0x9660f1.balance-=_0x0848bc;
                LogFile.AddMessage(msg.sender,_0x0848bc,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
    }

    struct Holder
    {
        uint _0xbc406f;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 2 ether;

    function U_BANK(address _0x7a0d4f) public{
        LogFile = Log(_0x7a0d4f);
    }
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

    function AddMessage(address _0x5d5ff3,uint _0x927dcb,string _0x81c189)
    public
    {
        LastMsg.Sender = _0x5d5ff3;
        LastMsg.Time = _0x91806f;
        LastMsg.Val = _0x927dcb;
        LastMsg.Data = _0x81c189;
        History.push(LastMsg);
    }
}