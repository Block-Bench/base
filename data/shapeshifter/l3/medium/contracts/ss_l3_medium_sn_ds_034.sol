// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint _0xd6ad52;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    Log LogFile;

    bool _0xfb835d;

    function SetMinSum(uint _0x370aeb)
    public
    {
        if(_0xfb835d)throw;
        MinSum = _0x370aeb;
    }

    function SetLogFile(address _0x15d188)
    public
    {
        if(_0xfb835d)throw;
        LogFile = Log(_0x15d188);
    }

    function Initialized()
    public
    {
        _0xfb835d = true;
    }

    function Put(uint _0x6883a8)
    public
    payable
    {
        var _0x3285dd = Acc[msg.sender];
        _0x3285dd.balance += msg.value;
        if(_0xa41ee5+_0x6883a8>_0x3285dd._0xd6ad52)_0x3285dd._0xd6ad52=_0xa41ee5+_0x6883a8;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xb20c22)
    public
    payable
    {
        var _0x3285dd = Acc[msg.sender];
        if( _0x3285dd.balance>=MinSum && _0x3285dd.balance>=_0xb20c22 && _0xa41ee5>_0x3285dd._0xd6ad52)
        {
            if(msg.sender.call.value(_0xb20c22)())
            {
                _0x3285dd.balance-=_0xb20c22;
                LogFile.AddMessage(msg.sender,_0xb20c22,"Collect");
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

    function AddMessage(address _0x4b68af,uint _0x370aeb,string _0xde3ca0)
    public
    {
        LastMsg.Sender = _0x4b68af;
        LastMsg.Time = _0xa41ee5;
        LastMsg.Val = _0x370aeb;
        LastMsg.Data = _0xde3ca0;
        History.push(LastMsg);
    }
}