pragma solidity ^0.4.19;

contract ACCURAL_DEPOSIT
{
    mapping (address=>uint256) public _0x49a260;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0x249428;

    function SetMinSum(uint _0x8de725)
    public
    {
        if(_0x249428)revert();
        MinSum = _0x8de725;
    }

    function SetLogFile(address _0x7e6efb)
    public
    {
        if(_0x249428)revert();
        Log = LogFile(_0x7e6efb);
    }

    function Initialized()
    public
    {
        _0x249428 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x49a260[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x8e21a9)
    public
    payable
    {
        if(_0x49a260[msg.sender]>=MinSum && _0x49a260[msg.sender]>=_0x8e21a9)
        {
            if(msg.sender.call.value(_0x8e21a9)())
            {
                _0x49a260[msg.sender]-=_0x8e21a9;
                Log.AddMessage(msg.sender,_0x8e21a9,"Collect");
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

    function AddMessage(address _0x1780ce,uint _0x8de725,string _0x1025a0)
    public
    {
        LastMsg.Sender = _0x1780ce;
        LastMsg.Time = _0xb7501a;
        LastMsg.Val = _0x8de725;
        LastMsg.Data = _0x1025a0;
        History.push(LastMsg);
    }
}