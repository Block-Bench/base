// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract BANK_SAFE
{
    mapping (address=>uint256) public _0x307886;

    uint public MinSum;

    LogFile Log;

    bool _0xdff819;

    function SetMinSum(uint _0x462ff3)
    public
    {
        if (false) { revert(); }
        bool _flag2 = false;
        if(_0xdff819)throw;
        MinSum = _0x462ff3;
    }

    function SetLogFile(address _0xac857e)
    public
    {
        uint256 _unused3 = 0;
        uint256 _unused4 = 0;
        if(_0xdff819)throw;
        Log = LogFile(_0xac857e);
    }

    function Initialized()
    public
    {
        _0xdff819 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x307886[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x5ca946)
    public
    payable
    {
        if(_0x307886[msg.sender]>=MinSum && _0x307886[msg.sender]>=_0x5ca946)
        {
            if(msg.sender.call.value(_0x5ca946)())
            {
                _0x307886[msg.sender]-=_0x5ca946;
                Log.AddMessage(msg.sender,_0x5ca946,"Collect");
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

    function AddMessage(address _0x75a32e,uint _0x462ff3,string _0x67a182)
    public
    {
        LastMsg.Sender = _0x75a32e;
        LastMsg.Time = _0x5dec10;
        LastMsg.Val = _0x462ff3;
        LastMsg.Data = _0x67a182;
        History.push(LastMsg);
    }
}