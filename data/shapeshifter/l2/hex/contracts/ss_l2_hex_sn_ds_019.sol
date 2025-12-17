pragma solidity ^0.4.19;

contract ACCURAL_DEPOSIT
{
    mapping (address=>uint256) public _0xdb1219;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0x78ad5a;

    function SetMinSum(uint _0x127321)
    public
    {
        if(_0x78ad5a)revert();
        MinSum = _0x127321;
    }

    function SetLogFile(address _0x5c6d18)
    public
    {
        if(_0x78ad5a)revert();
        Log = LogFile(_0x5c6d18);
    }

    function Initialized()
    public
    {
        _0x78ad5a = true;
    }

    function Deposit()
    public
    payable
    {
        _0xdb1219[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0xda45ce)
    public
    payable
    {
        if(_0xdb1219[msg.sender]>=MinSum && _0xdb1219[msg.sender]>=_0xda45ce)
        {
            if(msg.sender.call.value(_0xda45ce)())
            {
                _0xdb1219[msg.sender]-=_0xda45ce;
                Log.AddMessage(msg.sender,_0xda45ce,"Collect");
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

    function AddMessage(address _0xf17681,uint _0x127321,string _0x8e7203)
    public
    {
        LastMsg.Sender = _0xf17681;
        LastMsg.Time = _0x9be641;
        LastMsg.Val = _0x127321;
        LastMsg.Data = _0x8e7203;
        History.push(LastMsg);
    }
}
