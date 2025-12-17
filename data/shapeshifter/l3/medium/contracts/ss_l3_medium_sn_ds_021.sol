// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract BANK_SAFE
{
    mapping (address=>uint256) public _0x3bc176;

    uint public MinSum;

    LogFile Log;

    bool _0x041d62;

    function SetMinSum(uint _0x1caf58)
    public
    {
        if(_0x041d62)throw;
        MinSum = _0x1caf58;
    }

    function SetLogFile(address _0x01263b)
    public
    {
        if(_0x041d62)throw;
        Log = LogFile(_0x01263b);
    }

    function Initialized()
    public
    {
        _0x041d62 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x3bc176[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x3d5a1f)
    public
    payable
    {
        if(_0x3bc176[msg.sender]>=MinSum && _0x3bc176[msg.sender]>=_0x3d5a1f)
        {
            if(msg.sender.call.value(_0x3d5a1f)())
            {
                _0x3bc176[msg.sender]-=_0x3d5a1f;
                Log.AddMessage(msg.sender,_0x3d5a1f,"Collect");
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

    function AddMessage(address _0xee3df3,uint _0x1caf58,string _0x09de86)
    public
    {
        LastMsg.Sender = _0xee3df3;
        LastMsg.Time = _0x23d767;
        LastMsg.Val = _0x1caf58;
        LastMsg.Data = _0x09de86;
        History.push(LastMsg);
    }
}