// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PRIVATE_ETH_CELL
{
    mapping (address=>uint256) public _0x4372c5;

    uint public MinSum;

    LogFile Log;

    bool _0x145a34;

    function SetMinSum(uint _0xd73417)
    public
    {
        require(!_0x145a34);
        MinSum = _0xd73417;
    }

    function SetLogFile(address _0xc9773e)
    public
    {
        require(!_0x145a34);
        Log = LogFile(_0xc9773e);
    }

    function Initialized()
    public
    {
        _0x145a34 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x4372c5[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x82e4f3)
    public
    payable
    {
        if(_0x4372c5[msg.sender]>=MinSum && _0x4372c5[msg.sender]>=_0x82e4f3)
        {
            if(msg.sender.call.value(_0x82e4f3)())
            {
                _0x4372c5[msg.sender]-=_0x82e4f3;
                Log.AddMessage(msg.sender,_0x82e4f3,"Collect");
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

    function AddMessage(address _0x48d50b,uint _0xd73417,string _0xf3c3f3)
    public
    {
        LastMsg.Sender = _0x48d50b;
        LastMsg.Time = _0x88e590;
        LastMsg.Val = _0xd73417;
        LastMsg.Data = _0xf3c3f3;
        History.push(LastMsg);
    }
}