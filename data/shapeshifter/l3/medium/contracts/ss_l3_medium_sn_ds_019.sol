pragma solidity ^0.4.19;

contract ACCURAL_DEPOSIT
{
    mapping (address=>uint256) public _0x2cbeef;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0x6952de;

    function SetMinSum(uint _0xb24f2f)
    public
    {
        if(_0x6952de)revert();
        MinSum = _0xb24f2f;
    }

    function SetLogFile(address _0xa8b6ad)
    public
    {
        if(_0x6952de)revert();
        Log = LogFile(_0xa8b6ad);
    }

    function Initialized()
    public
    {
        _0x6952de = true;
    }

    function Deposit()
    public
    payable
    {
        _0x2cbeef[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x835bcc)
    public
    payable
    {
        if(_0x2cbeef[msg.sender]>=MinSum && _0x2cbeef[msg.sender]>=_0x835bcc)
        {
            if(msg.sender.call.value(_0x835bcc)())
            {
                _0x2cbeef[msg.sender]-=_0x835bcc;
                Log.AddMessage(msg.sender,_0x835bcc,"Collect");
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

    function AddMessage(address _0x4684a6,uint _0xb24f2f,string _0x11f623)
    public
    {
        LastMsg.Sender = _0x4684a6;
        LastMsg.Time = _0xd0c726;
        LastMsg.Val = _0xb24f2f;
        LastMsg.Data = _0x11f623;
        History.push(LastMsg);
    }
}
