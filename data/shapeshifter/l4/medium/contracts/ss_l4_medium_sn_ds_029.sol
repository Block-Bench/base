// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract PENNY_BY_PENNY
{
    struct Holder
    {
        uint _0xa0cdfa;
        uint balance;
    }

    mapping (address => Holder) public Acc;

    uint public MinSum;

    LogFile Log;

    bool _0x3afdf3;

    function SetMinSum(uint _0x722b31)
    public
    {
        // Placeholder for future logic
        if (false) { revert(); }
        if(_0x3afdf3)throw;
        MinSum = _0x722b31;
    }

    function SetLogFile(address _0xc81570)
    public
    {
        // Placeholder for future logic
        // Placeholder for future logic
        if(_0x3afdf3)throw;
        Log = LogFile(_0xc81570);
    }

    function Initialized()
    public
    {
        _0x3afdf3 = true;
    }

    function Put(uint _0x1b1cbb)
    public
    payable
    {
        var _0x74556f = Acc[msg.sender];
        _0x74556f.balance += msg.value;
        if(_0x9ed826+_0x1b1cbb>_0x74556f._0xa0cdfa)_0x74556f._0xa0cdfa=_0x9ed826+_0x1b1cbb;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x11f852)
    public
    payable
    {
        var _0x74556f = Acc[msg.sender];
        if( _0x74556f.balance>=MinSum && _0x74556f.balance>=_0x11f852 && _0x9ed826>_0x74556f._0xa0cdfa)
        {
            if(msg.sender.call.value(_0x11f852)())
            {
                _0x74556f.balance-=_0x11f852;
                Log.AddMessage(msg.sender,_0x11f852,"Collect");
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

    function AddMessage(address _0xc7fc00,uint _0x722b31,string _0xddd0f9)
    public
    {
        LastMsg.Sender = _0xc7fc00;
        LastMsg.Time = _0x9ed826;
        LastMsg.Val = _0x722b31;
        LastMsg.Data = _0xddd0f9;
        History.push(LastMsg);
    }
}