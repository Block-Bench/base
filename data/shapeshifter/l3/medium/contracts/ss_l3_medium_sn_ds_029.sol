// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct Holder
    {
        uint _0x4d5a39;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    LogFile Log;

    bool _0xf92fec;

    function SetMinSum(uint _0xc93eb7)
    public
    {
        if(_0xf92fec)throw;
        MinSum = _0xc93eb7;
    }

    function SetLogFile(address _0x6e0153)
    public
    {
        if(_0xf92fec)throw;
        Log = LogFile(_0x6e0153);
    }

    function Initialized()
    public
    {
        _0xf92fec = true;
    }

    function Put(uint _0x0ccc9d)
    public
    payable
    {
        var _0x636d91 = Acc[msg.sender];
        _0x636d91.balance += msg.value;
        if(_0x86d14b+_0x0ccc9d>_0x636d91._0x4d5a39)_0x636d91._0x4d5a39=_0x86d14b+_0x0ccc9d;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x3757b3)
    public
    payable
    {
        var _0x636d91 = Acc[msg.sender];
        if( _0x636d91.balance>=MinSum && _0x636d91.balance>=_0x3757b3 && _0x86d14b>_0x636d91._0x4d5a39)
        {
            if(msg.sender.call.value(_0x3757b3)())
            {
                _0x636d91.balance-=_0x3757b3;
                Log.AddMessage(msg.sender,_0x3757b3,"Collect");
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

contract LogFile
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

    function AddMessage(address _0x61d0d0,uint _0xc93eb7,string _0x1fa100)
    public
    {
        LastMsg.Sender = _0x61d0d0;
        LastMsg.Time = _0x86d14b;
        LastMsg.Val = _0xc93eb7;
        LastMsg.Data = _0x1fa100;
        History.push(LastMsg);
    }
}