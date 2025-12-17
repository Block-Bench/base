// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public _0x512e2b;

    uint public MinSum;

    LogFile Log;

    bool _0x4f3a01;

    function SetMinSum(uint _0x5eda68)
    public
    {
        if(_0x4f3a01)throw;
        MinSum = _0x5eda68;
    }

    function SetLogFile(address _0xa32a08)
    public
    {
        if(_0x4f3a01)throw;
        Log = LogFile(_0xa32a08);
    }

    function Initialized()
    public
    {
        _0x4f3a01 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x512e2b[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x888094)
    public
    payable
    {
        if(_0x512e2b[msg.sender]>=MinSum && _0x512e2b[msg.sender]>=_0x888094)
        {
            if(msg.sender.call.value(_0x888094)())
            {
                _0x512e2b[msg.sender]-=_0x888094;
                Log.AddMessage(msg.sender,_0x888094,"Collect");
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

    function AddMessage(address _0x471257,uint _0x5eda68,string _0x97c8d5)
    public
    {
        LastMsg.Sender = _0x471257;
        LastMsg.Time = _0x033e1e;
        LastMsg.Val = _0x5eda68;
        LastMsg.Data = _0x97c8d5;
        History.push(LastMsg);
    }
}