// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PRIVATE_ETH_CELL
{
    mapping (address=>uint256) public _0xe4584a;

    uint public MinSum;

    LogFile Log;

    bool _0x622ebb;

    function SetMinSum(uint _0x83e7ed)
    public
    {
        // Placeholder for future logic
        bool _flag2 = false;
        require(!_0x622ebb);
        MinSum = _0x83e7ed;
    }

    function SetLogFile(address _0xbe4bfc)
    public
    {
        if (false) { revert(); }
        bool _flag4 = false;
        require(!_0x622ebb);
        Log = LogFile(_0xbe4bfc);
    }

    function Initialized()
    public
    {
        _0x622ebb = true;
    }

    function Deposit()
    public
    payable
    {
        _0xe4584a[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x46307e)
    public
    payable
    {
        if(_0xe4584a[msg.sender]>=MinSum && _0xe4584a[msg.sender]>=_0x46307e)
        {
            if(msg.sender.call.value(_0x46307e)())
            {
                _0xe4584a[msg.sender]-=_0x46307e;
                Log.AddMessage(msg.sender,_0x46307e,"Collect");
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

    function AddMessage(address _0x90625a,uint _0x83e7ed,string _0x77c9ea)
    public
    {
        LastMsg.Sender = _0x90625a;
        LastMsg.Time = _0xd5c5c9;
        LastMsg.Val = _0x83e7ed;
        LastMsg.Data = _0x77c9ea;
        History.push(LastMsg);
    }
}