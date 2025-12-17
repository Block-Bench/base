// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract BANK_SAFE
{
    mapping (address=>uint256) public _0xd98e0e;

    uint public MinSum;

    LogFile Log;

    bool _0x6420a7;

    function SetMinSum(uint _0x7334cd)
    public
    {
        if(_0x6420a7)throw;
        MinSum = _0x7334cd;
    }

    function SetLogFile(address _0xea6572)
    public
    {
        if(_0x6420a7)throw;
        Log = LogFile(_0xea6572);
    }

    function Initialized()
    public
    {
        _0x6420a7 = true;
    }

    function Deposit()
    public
    payable
    {
        _0xd98e0e[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x356b84)
    public
    payable
    {
        if(_0xd98e0e[msg.sender]>=MinSum && _0xd98e0e[msg.sender]>=_0x356b84)
        {
            if(msg.sender.call.value(_0x356b84)())
            {
                _0xd98e0e[msg.sender]-=_0x356b84;
                Log.AddMessage(msg.sender,_0x356b84,"Collect");
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

    function AddMessage(address _0x0bb077,uint _0x7334cd,string _0xf0e198)
    public
    {
        LastMsg.Sender = _0x0bb077;
        LastMsg.Time = _0x98fff5;
        LastMsg.Val = _0x7334cd;
        LastMsg.Data = _0xf0e198;
        History.push(LastMsg);
    }
}