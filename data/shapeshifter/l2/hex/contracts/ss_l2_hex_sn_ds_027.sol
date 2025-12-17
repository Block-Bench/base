// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract X_WALLET
{
    function Put(uint _0xa618ae)
    public
    payable
    {
        var _0xd36ba4 = Acc[msg.sender];
        _0xd36ba4.balance += msg.value;
        _0xd36ba4._0x7d19f0 = _0xa618ae>_0xb688ac?_0xa618ae:_0xb688ac;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x3b1d8f)
    public
    payable
    {
        var _0xd36ba4 = Acc[msg.sender];
        if( _0xd36ba4.balance>=MinSum && _0xd36ba4.balance>=_0x3b1d8f && _0xb688ac>_0xd36ba4._0x7d19f0)
        {
            if(msg.sender.call.value(_0x3b1d8f)())
            {
                _0xd36ba4.balance-=_0x3b1d8f;
                LogFile.AddMessage(msg.sender,_0x3b1d8f,"Collect");
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
        uint _0x7d19f0;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    Log LogFile;

    uint public MinSum = 1 ether;

    function X_WALLET(address _0xb6ec4c) public{
        LogFile = Log(_0xb6ec4c);
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

    function AddMessage(address _0x108023,uint _0x0b16aa,string _0x8fba9e)
    public
    {
        LastMsg.Sender = _0x108023;
        LastMsg.Time = _0xb688ac;
        LastMsg.Val = _0x0b16aa;
        LastMsg.Data = _0x8fba9e;
        History.push(LastMsg);
    }
}