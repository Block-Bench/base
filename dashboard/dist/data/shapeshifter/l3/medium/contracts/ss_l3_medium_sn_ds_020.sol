// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PRIVATE_ETH_CELL
{
    mapping (address=>uint256) public _0x54397a;

    uint public MinSum;

    LogFile Log;

    bool _0xb03f1c;

    function SetMinSum(uint _0x7070fc)
    public
    {
        require(!_0xb03f1c);
        MinSum = _0x7070fc;
    }

    function SetLogFile(address _0xcefd83)
    public
    {
        require(!_0xb03f1c);
        Log = LogFile(_0xcefd83);
    }

    function Initialized()
    public
    {
        _0xb03f1c = true;
    }

    function Deposit()
    public
    payable
    {
        _0x54397a[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xaca5ca)
    public
    payable
    {
        if(_0x54397a[msg.sender]>=MinSum && _0x54397a[msg.sender]>=_0xaca5ca)
        {
            if(msg.sender.call.value(_0xaca5ca)())
            {
                _0x54397a[msg.sender]-=_0xaca5ca;
                Log.AddMessage(msg.sender,_0xaca5ca,"Collect");
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

    function AddMessage(address _0x87e47d,uint _0x7070fc,string _0xd37f42)
    public
    {
        LastMsg.Sender = _0x87e47d;
        LastMsg.Time = _0x9c1a30;
        LastMsg.Val = _0x7070fc;
        LastMsg.Data = _0xd37f42;
        History.push(LastMsg);
    }
}