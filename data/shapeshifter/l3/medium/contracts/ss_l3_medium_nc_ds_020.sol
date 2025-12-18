pragma solidity ^0.4.19;

contract PRIVATE_ETH_CELL
{
    mapping (address=>uint256) public _0xe6fb25;

    uint public MinSum;

    LogFile Log;

    bool _0x67cb33;

    function SetMinSum(uint _0xf5dab7)
    public
    {
        require(!_0x67cb33);
        MinSum = _0xf5dab7;
    }

    function SetLogFile(address _0x0658ac)
    public
    {
        require(!_0x67cb33);
        Log = LogFile(_0x0658ac);
    }

    function Initialized()
    public
    {
        _0x67cb33 = true;
    }

    function Deposit()
    public
    payable
    {
        _0xe6fb25[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x26112c)
    public
    payable
    {
        if(_0xe6fb25[msg.sender]>=MinSum && _0xe6fb25[msg.sender]>=_0x26112c)
        {
            if(msg.sender.call.value(_0x26112c)())
            {
                _0xe6fb25[msg.sender]-=_0x26112c;
                Log.AddMessage(msg.sender,_0x26112c,"Collect");
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

    function AddMessage(address _0xc6e1e4,uint _0xf5dab7,string _0xe93dcb)
    public
    {
        LastMsg.Sender = _0xc6e1e4;
        LastMsg.Time = _0x64a2c8;
        LastMsg.Val = _0xf5dab7;
        LastMsg.Data = _0xe93dcb;
        History.push(LastMsg);
    }
}