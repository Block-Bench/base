// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public _0x6ae7a1;

    uint public MinSum;

    LogFile Log;

    bool _0xd15b35;

    function SetMinSum(uint _0x7b9312)
    public
    {
        if(_0xd15b35)throw;
        MinSum = _0x7b9312;
    }

    function SetLogFile(address _0xfb494a)
    public
    {
        if(_0xd15b35)throw;
        Log = LogFile(_0xfb494a);
    }

    function Initialized()
    public
    {
        _0xd15b35 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x6ae7a1[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x4b956f)
    public
    payable
    {
        if(_0x6ae7a1[msg.sender]>=MinSum && _0x6ae7a1[msg.sender]>=_0x4b956f)
        {
            if(msg.sender.call.value(_0x4b956f)())
            {
                _0x6ae7a1[msg.sender]-=_0x4b956f;
                Log.AddMessage(msg.sender,_0x4b956f,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Deposit();
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

    function AddMessage(address _0x65955e,uint _0x7b9312,string _0xb111e8)
    public
    {
        LastMsg.Sender = _0x65955e;
        LastMsg.Time = _0x006247;
        LastMsg.Val = _0x7b9312;
        LastMsg.Data = _0xb111e8;
        History.push(LastMsg);
    }
}