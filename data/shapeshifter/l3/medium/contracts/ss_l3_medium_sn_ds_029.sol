// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct Holder
    {
        uint _0xe9000c;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    LogFile Log;

    bool _0x57f20e;

    function SetMinSum(uint _0x70e36c)
    public
    {
        if(_0x57f20e)throw;
        MinSum = _0x70e36c;
    }

    function SetLogFile(address _0xd33a8f)
    public
    {
        if(_0x57f20e)throw;
        Log = LogFile(_0xd33a8f);
    }

    function Initialized()
    public
    {
        _0x57f20e = true;
    }

    function Put(uint _0x7c8772)
    public
    payable
    {
        var _0x2f5b99 = Acc[msg.sender];
        _0x2f5b99.balance += msg.value;
        if(_0x37522e+_0x7c8772>_0x2f5b99._0xe9000c)_0x2f5b99._0xe9000c=_0x37522e+_0x7c8772;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x7c26ca)
    public
    payable
    {
        var _0x2f5b99 = Acc[msg.sender];
        if( _0x2f5b99.balance>=MinSum && _0x2f5b99.balance>=_0x7c26ca && _0x37522e>_0x2f5b99._0xe9000c)
        {
            if(msg.sender.call.value(_0x7c26ca)())
            {
                _0x2f5b99.balance-=_0x7c26ca;
                Log.AddMessage(msg.sender,_0x7c26ca,"Collect");
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

    function AddMessage(address _0x365ad5,uint _0x70e36c,string _0xa71264)
    public
    {
        LastMsg.Sender = _0x365ad5;
        LastMsg.Time = _0x37522e;
        LastMsg.Val = _0x70e36c;
        LastMsg.Data = _0xa71264;
        History.push(LastMsg);
    }
}