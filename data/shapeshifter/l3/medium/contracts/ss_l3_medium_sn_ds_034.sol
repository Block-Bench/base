// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract MONEY_BOX
{
    struct Holder
    {
        uint _0xffd795;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    Log LogFile;

    bool _0x6e120f;

    function SetMinSum(uint _0x4ef573)
    public
    {
        if(_0x6e120f)throw;
        MinSum = _0x4ef573;
    }

    function SetLogFile(address _0x794936)
    public
    {
        if(_0x6e120f)throw;
        LogFile = Log(_0x794936);
    }

    function Initialized()
    public
    {
        _0x6e120f = true;
    }

    function Put(uint _0xae3b59)
    public
    payable
    {
        var _0xafed77 = Acc[msg.sender];
        _0xafed77.balance += msg.value;
        if(_0xb74657+_0xae3b59>_0xafed77._0xffd795)_0xafed77._0xffd795=_0xb74657+_0xae3b59;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x619e9e)
    public
    payable
    {
        var _0xafed77 = Acc[msg.sender];
        if( _0xafed77.balance>=MinSum && _0xafed77.balance>=_0x619e9e && _0xb74657>_0xafed77._0xffd795)
        {
            if(msg.sender.call.value(_0x619e9e)())
            {
                _0xafed77.balance-=_0x619e9e;
                LogFile.AddMessage(msg.sender,_0x619e9e,"Collect");
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

contract Log
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

    function AddMessage(address _0x451125,uint _0x4ef573,string _0x10576e)
    public
    {
        LastMsg.Sender = _0x451125;
        LastMsg.Time = _0xb74657;
        LastMsg.Val = _0x4ef573;
        LastMsg.Data = _0x10576e;
        History.push(LastMsg);
    }
}