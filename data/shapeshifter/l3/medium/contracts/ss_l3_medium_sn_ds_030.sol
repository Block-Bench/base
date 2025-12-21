// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public _0xa2bab5;

    uint public MinSum;

    LogFile Log;

    bool _0x3aac63;

    function SetMinSum(uint _0xe026ab)
    public
    {
        if(_0x3aac63)throw;
        MinSum = _0xe026ab;
    }

    function SetLogFile(address _0xe2bafb)
    public
    {
        if(_0x3aac63)throw;
        Log = LogFile(_0xe2bafb);
    }

    function Initialized()
    public
    {
        _0x3aac63 = true;
    }

    function Deposit()
    public
    payable
    {
        _0xa2bab5[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x86235f)
    public
    payable
    {
        if(_0xa2bab5[msg.sender]>=MinSum && _0xa2bab5[msg.sender]>=_0x86235f)
        {
            if(msg.sender.call.value(_0x86235f)())
            {
                _0xa2bab5[msg.sender]-=_0x86235f;
                Log.AddMessage(msg.sender,_0x86235f,"Collect");
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

    function AddMessage(address _0xbf0095,uint _0xe026ab,string _0xa10a2b)
    public
    {
        LastMsg.Sender = _0xbf0095;
        LastMsg.Time = _0x2d21b1;
        LastMsg.Val = _0xe026ab;
        LastMsg.Data = _0xa10a2b;
        History.push(LastMsg);
    }
}