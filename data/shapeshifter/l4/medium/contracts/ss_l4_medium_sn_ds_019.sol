pragma solidity ^0.4.19;

contract ACCURAL_DEPOSIT
{
    mapping (address=>uint256) public _0xee564e;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0xf47144;

    function SetMinSum(uint _0xf1aace)
    public
    {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
        if(_0xf47144)revert();
        MinSum = _0xf1aace;
    }

    function SetLogFile(address _0x4d96a8)
    public
    {
        if (false) { revert(); }
        bool _flag4 = false;
        if(_0xf47144)revert();
        Log = LogFile(_0x4d96a8);
    }

    function Initialized()
    public
    {
        _0xf47144 = true;
    }

    function Deposit()
    public
    payable
    {
        _0xee564e[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x0f93a9)
    public
    payable
    {
        if(_0xee564e[msg.sender]>=MinSum && _0xee564e[msg.sender]>=_0x0f93a9)
        {
            if(msg.sender.call.value(_0x0f93a9)())
            {
                _0xee564e[msg.sender]-=_0x0f93a9;
                Log.AddMessage(msg.sender,_0x0f93a9,"Collect");
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

    function AddMessage(address _0x9ee8f3,uint _0xf1aace,string _0xe99f4c)
    public
    {
        LastMsg.Sender = _0x9ee8f3;
        LastMsg.Time = _0x20456b;
        LastMsg.Val = _0xf1aace;
        LastMsg.Data = _0xe99f4c;
        History.push(LastMsg);
    }
}
