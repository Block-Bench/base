pragma solidity ^0.4.19;

contract PERSONAL_BANK
{
    mapping (address=>uint256) public _0x6fc545;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0x336d96;

    function SetMinSum(uint _0x45f2f7)
    public
    {
        if(_0x336d96)revert();
        MinSum = _0x45f2f7;
    }

    function SetLogFile(address _0x845dbb)
    public
    {
        if(_0x336d96)revert();
        Log = LogFile(_0x845dbb);
    }

    function Initialized()
    public
    {
        _0x336d96 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x6fc545[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x64fe8c)
    public
    payable
    {
        if(_0x6fc545[msg.sender]>=MinSum && _0x6fc545[msg.sender]>=_0x64fe8c)
        {
            if(msg.sender.call.value(_0x64fe8c)())
            {
                _0x6fc545[msg.sender]-=_0x64fe8c;
                Log.AddMessage(msg.sender,_0x64fe8c,"Collect");
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

    function AddMessage(address _0xf7d5ad,uint _0x45f2f7,string _0xfc4641)
    public
    {
        LastMsg.Sender = _0xf7d5ad;
        LastMsg.Time = _0xd7a89e;
        LastMsg.Val = _0x45f2f7;
        LastMsg.Data = _0xfc4641;
        History.push(LastMsg);
    }
}