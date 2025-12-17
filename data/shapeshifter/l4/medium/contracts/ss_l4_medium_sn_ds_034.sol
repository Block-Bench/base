// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint _0xa7cd53;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    Log LogFile;

    bool _0xc81686;

    function SetMinSum(uint _0x13706a)
    public
    {
        // Placeholder for future logic
        if (false) { revert(); }
        if(_0xc81686)throw;
        MinSum = _0x13706a;
    }

    function SetLogFile(address _0xdd452b)
    public
    {
        bool _flag3 = false;
        if (false) { revert(); }
        if(_0xc81686)throw;
        LogFile = Log(_0xdd452b);
    }

    function Initialized()
    public
    {
        _0xc81686 = true;
    }

    function Put(uint _0xb4c89d)
    public
    payable
    {
        var _0x21348b = Acc[msg.sender];
        _0x21348b.balance += msg.value;
        if(_0x41c328+_0xb4c89d>_0x21348b._0xa7cd53)_0x21348b._0xa7cd53=_0x41c328+_0xb4c89d;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x8dfeb3)
    public
    payable
    {
        var _0x21348b = Acc[msg.sender];
        if( _0x21348b.balance>=MinSum && _0x21348b.balance>=_0x8dfeb3 && _0x41c328>_0x21348b._0xa7cd53)
        {
            if(msg.sender.call.value(_0x8dfeb3)())
            {
                _0x21348b.balance-=_0x8dfeb3;
                LogFile.AddMessage(msg.sender,_0x8dfeb3,"Collect");
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

    function AddMessage(address _0xb1f03c,uint _0x13706a,string _0x9746a6)
    public
    {
        LastMsg.Sender = _0xb1f03c;
        LastMsg.Time = _0x41c328;
        LastMsg.Val = _0x13706a;
        LastMsg.Data = _0x9746a6;
        History.push(LastMsg);
    }
}