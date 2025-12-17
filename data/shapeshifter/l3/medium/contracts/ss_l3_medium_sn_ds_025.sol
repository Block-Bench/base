// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract W_WALLET
{
    function Put(uint _0x5ec716)
    public
    payable
    {
        var _0x398d3d = Acc[msg.sender];
        _0x398d3d.balance += msg.value;
        _0x398d3d._0xc364a5 = _0x5ec716>_0x6894b2?_0x5ec716:_0x6894b2;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x92bdb6)
    public
    payable
    {
        var _0x398d3d = Acc[msg.sender];
        if( _0x398d3d.balance>=MinSum && _0x398d3d.balance>=_0x92bdb6 && _0x6894b2>_0x398d3d._0xc364a5)
        {
            if(msg.sender.call.value(_0x92bdb6)())
            {
                _0x398d3d.balance-=_0x92bdb6;
                LogFile.AddMessage(msg.sender,_0x92bdb6,"Collect");
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
        uint _0xc364a5;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function W_WALLET(address _0x588b73) public{
        LogFile = Log(_0x588b73);
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

    function AddMessage(address _0xdf7d27,uint _0xfe30ba,string _0xb726cd)
    public
    {
        LastMsg.Sender = _0xdf7d27;
        LastMsg.Time = _0x6894b2;
        LastMsg.Val = _0xfe30ba;
        LastMsg.Data = _0xb726cd;
        History.push(LastMsg);
    }
}