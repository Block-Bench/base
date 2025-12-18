pragma solidity ^0.4.19;

contract PRIVATE_ETH_CELL
{
    mapping (address=>uint256) public _0xa27cca;

    uint public MinSum;

    LogFile Log;

    bool _0x6fbab9;

    function SetMinSum(uint _0x44c96a)
    public
    {
        require(!_0x6fbab9);
        MinSum = _0x44c96a;
    }

    function SetLogFile(address _0xab0ac1)
    public
    {
        require(!_0x6fbab9);
        Log = LogFile(_0xab0ac1);
    }

    function Initialized()
    public
    {
        _0x6fbab9 = true;
    }

    function Deposit()
    public
    payable
    {
        _0xa27cca[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x9d0415)
    public
    payable
    {
        if(_0xa27cca[msg.sender]>=MinSum && _0xa27cca[msg.sender]>=_0x9d0415)
        {
            if(msg.sender.call.value(_0x9d0415)())
            {
                _0xa27cca[msg.sender]-=_0x9d0415;
                Log.AddMessage(msg.sender,_0x9d0415,"Collect");
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

    function AddMessage(address _0xff0dfd,uint _0x44c96a,string _0x5f5436)
    public
    {
        LastMsg.Sender = _0xff0dfd;
        LastMsg.Time = _0x7c2692;
        LastMsg.Val = _0x44c96a;
        LastMsg.Data = _0x5f5436;
        History.push(LastMsg);
    }
}