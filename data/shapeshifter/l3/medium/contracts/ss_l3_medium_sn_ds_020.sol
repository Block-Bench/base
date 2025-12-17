// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PRIVATE_ETH_CELL
{
    mapping (address=>uint256) public _0x4f7e3c;

    uint public MinSum;

    LogFile Log;

    bool _0x539ec3;

    function SetMinSum(uint _0x0bcdce)
    public
    {
        require(!_0x539ec3);
        MinSum = _0x0bcdce;
    }

    function SetLogFile(address _0xbee541)
    public
    {
        require(!_0x539ec3);
        Log = LogFile(_0xbee541);
    }

    function Initialized()
    public
    {
        _0x539ec3 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x4f7e3c[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x75a265)
    public
    payable
    {
        if(_0x4f7e3c[msg.sender]>=MinSum && _0x4f7e3c[msg.sender]>=_0x75a265)
        {
            if(msg.sender.call.value(_0x75a265)())
            {
                _0x4f7e3c[msg.sender]-=_0x75a265;
                Log.AddMessage(msg.sender,_0x75a265,"Collect");
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

    function AddMessage(address _0xcf5e3b,uint _0x0bcdce,string _0xd2fc28)
    public
    {
        LastMsg.Sender = _0xcf5e3b;
        LastMsg.Time = _0xb1f41c;
        LastMsg.Val = _0x0bcdce;
        LastMsg.Data = _0xd2fc28;
        History.push(LastMsg);
    }
}