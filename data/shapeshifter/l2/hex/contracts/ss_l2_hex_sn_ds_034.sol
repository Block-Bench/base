// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint _0x4207c5;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    Log LogFile;

    bool _0xdf7a32;

    function SetMinSum(uint _0x7a0c00)
    public
    {
        if(_0xdf7a32)throw;
        MinSum = _0x7a0c00;
    }

    function SetLogFile(address _0x28b3b5)
    public
    {
        if(_0xdf7a32)throw;
        LogFile = Log(_0x28b3b5);
    }

    function Initialized()
    public
    {
        _0xdf7a32 = true;
    }

    function Put(uint _0x064311)
    public
    payable
    {
        var _0x537f37 = Acc[msg.sender];
        _0x537f37.balance += msg.value;
        if(_0x6ed151+_0x064311>_0x537f37._0x4207c5)_0x537f37._0x4207c5=_0x6ed151+_0x064311;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x22a8c4)
    public
    payable
    {
        var _0x537f37 = Acc[msg.sender];
        if( _0x537f37.balance>=MinSum && _0x537f37.balance>=_0x22a8c4 && _0x6ed151>_0x537f37._0x4207c5)
        {
            if(msg.sender.call.value(_0x22a8c4)())
            {
                _0x537f37.balance-=_0x22a8c4;
                LogFile.AddMessage(msg.sender,_0x22a8c4,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Put(0);
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

    function AddMessage(address _0xf3a07d,uint _0x7a0c00,string _0xba14f0)
    public
    {
        LastMsg.Sender = _0xf3a07d;
        LastMsg.Time = _0x6ed151;
        LastMsg.Val = _0x7a0c00;
        LastMsg.Data = _0xba14f0;
        History.push(LastMsg);
    }
}