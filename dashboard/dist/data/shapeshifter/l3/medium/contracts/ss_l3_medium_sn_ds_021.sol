// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract BANK_SAFE
{
    mapping (address=>uint256) public _0xcf041b;

    uint public MinSum;

    LogFile Log;

    bool _0x42c18d;

    function SetMinSum(uint _0xbac1ce)
    public
    {
        if(_0x42c18d)throw;
        MinSum = _0xbac1ce;
    }

    function SetLogFile(address _0x598a58)
    public
    {
        if(_0x42c18d)throw;
        Log = LogFile(_0x598a58);
    }

    function Initialized()
    public
    {
        _0x42c18d = true;
    }

    function Deposit()
    public
    payable
    {
        _0xcf041b[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x16caad)
    public
    payable
    {
        if(_0xcf041b[msg.sender]>=MinSum && _0xcf041b[msg.sender]>=_0x16caad)
        {
            if(msg.sender.call.value(_0x16caad)())
            {
                _0xcf041b[msg.sender]-=_0x16caad;
                Log.AddMessage(msg.sender,_0x16caad,"Collect");
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

    function AddMessage(address _0x6595a6,uint _0xbac1ce,string _0xfa1f30)
    public
    {
        LastMsg.Sender = _0x6595a6;
        LastMsg.Time = _0x931cec;
        LastMsg.Val = _0xbac1ce;
        LastMsg.Data = _0xfa1f30;
        History.push(LastMsg);
    }
}