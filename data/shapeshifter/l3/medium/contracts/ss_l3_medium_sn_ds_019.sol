pragma solidity ^0.4.19;

contract ACCURAL_DEPOSIT
{
    mapping (address=>uint256) public _0x7da43d;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0x4c7783;

    function SetMinSum(uint _0x73d47b)
    public
    {
        if(_0x4c7783)revert();
        MinSum = _0x73d47b;
    }

    function SetLogFile(address _0x14f004)
    public
    {
        if(_0x4c7783)revert();
        Log = LogFile(_0x14f004);
    }

    function Initialized()
    public
    {
        _0x4c7783 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x7da43d[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x2a28ca)
    public
    payable
    {
        if(_0x7da43d[msg.sender]>=MinSum && _0x7da43d[msg.sender]>=_0x2a28ca)
        {
            if(msg.sender.call.value(_0x2a28ca)())
            {
                _0x7da43d[msg.sender]-=_0x2a28ca;
                Log.AddMessage(msg.sender,_0x2a28ca,"Collect");
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

    function AddMessage(address _0x79e86b,uint _0x73d47b,string _0x1f071b)
    public
    {
        LastMsg.Sender = _0x79e86b;
        LastMsg.Time = _0x31a9e6;
        LastMsg.Val = _0x73d47b;
        LastMsg.Data = _0x1f071b;
        History.push(LastMsg);
    }
}
