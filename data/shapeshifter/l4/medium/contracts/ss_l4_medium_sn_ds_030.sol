// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public _0x4c289b;

    uint public MinSum;

    LogFile Log;

    bool _0xfb9989;

    function SetMinSum(uint _0x09b9a0)
    public
    {
        // Placeholder for future logic
        uint256 _unused2 = 0;
        if(_0xfb9989)throw;
        MinSum = _0x09b9a0;
    }

    function SetLogFile(address _0x02728e)
    public
    {
        // Placeholder for future logic
        uint256 _unused4 = 0;
        if(_0xfb9989)throw;
        Log = LogFile(_0x02728e);
    }

    function Initialized()
    public
    {
        _0xfb9989 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x4c289b[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x4e573c)
    public
    payable
    {
        if(_0x4c289b[msg.sender]>=MinSum && _0x4c289b[msg.sender]>=_0x4e573c)
        {
            if(msg.sender.call.value(_0x4e573c)())
            {
                _0x4c289b[msg.sender]-=_0x4e573c;
                Log.AddMessage(msg.sender,_0x4e573c,"Collect");
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

    function AddMessage(address _0x709200,uint _0x09b9a0,string _0xd3297d)
    public
    {
        LastMsg.Sender = _0x709200;
        LastMsg.Time = _0x86bc09;
        LastMsg.Val = _0x09b9a0;
        LastMsg.Data = _0xd3297d;
        History.push(LastMsg);
    }
}