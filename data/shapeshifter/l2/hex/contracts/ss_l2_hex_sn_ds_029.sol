// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct Holder
    {
        uint _0x390434;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    LogFile Log;

    bool _0x2f28af;

    function SetMinSum(uint _0x389aae)
    public
    {
        if(_0x2f28af)throw;
        MinSum = _0x389aae;
    }

    function SetLogFile(address _0x5291dd)
    public
    {
        if(_0x2f28af)throw;
        Log = LogFile(_0x5291dd);
    }

    function Initialized()
    public
    {
        _0x2f28af = true;
    }

    function Put(uint _0x5d6540)
    public
    payable
    {
        var _0x732727 = Acc[msg.sender];
        _0x732727.balance += msg.value;
        if(_0x49f335+_0x5d6540>_0x732727._0x390434)_0x732727._0x390434=_0x49f335+_0x5d6540;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x0c96e3)
    public
    payable
    {
        var _0x732727 = Acc[msg.sender];
        if( _0x732727.balance>=MinSum && _0x732727.balance>=_0x0c96e3 && _0x49f335>_0x732727._0x390434)
        {
            if(msg.sender.call.value(_0x0c96e3)())
            {
                _0x732727.balance-=_0x0c96e3;
                Log.AddMessage(msg.sender,_0x0c96e3,"Collect");
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

    function AddMessage(address _0x2182fb,uint _0x389aae,string _0x7ce89f)
    public
    {
        LastMsg.Sender = _0x2182fb;
        LastMsg.Time = _0x49f335;
        LastMsg.Val = _0x389aae;
        LastMsg.Data = _0x7ce89f;
        History.push(LastMsg);
    }
}