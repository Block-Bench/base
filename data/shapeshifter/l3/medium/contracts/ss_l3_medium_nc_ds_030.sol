pragma solidity ^0.4.19;

contract DEP_BANK
{
    mapping (address=>uint256) public _0xa7f016;

    uint public MinSum;

    LogFile Log;

    bool _0x25e97a;

    function SetMinSum(uint _0xc97d28)
    public
    {
        if(_0x25e97a)throw;
        MinSum = _0xc97d28;
    }

    function SetLogFile(address _0x8d2606)
    public
    {
        if(_0x25e97a)throw;
        Log = LogFile(_0x8d2606);
    }

    function Initialized()
    public
    {
        _0x25e97a = true;
    }

    function Deposit()
    public
    payable
    {
        _0xa7f016[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x2cc3dd)
    public
    payable
    {
        if(_0xa7f016[msg.sender]>=MinSum && _0xa7f016[msg.sender]>=_0x2cc3dd)
        {
            if(msg.sender.call.value(_0x2cc3dd)())
            {
                _0xa7f016[msg.sender]-=_0x2cc3dd;
                Log.AddMessage(msg.sender,_0x2cc3dd,"Collect");
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

    function AddMessage(address _0x84ad72,uint _0xc97d28,string _0x2bd035)
    public
    {
        LastMsg.Sender = _0x84ad72;
        LastMsg.Time = _0x71bd36;
        LastMsg.Val = _0xc97d28;
        LastMsg.Data = _0x2bd035;
        History.push(LastMsg);
    }
}