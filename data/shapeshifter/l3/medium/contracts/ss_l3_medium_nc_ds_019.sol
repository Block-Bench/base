pragma solidity ^0.4.19;

contract ACCURAL_DEPOSIT
{
    mapping (address=>uint256) public _0x6f6ee0;

    uint public MinSum = 1 ether;

    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool _0x7dee70;

    function SetMinSum(uint _0x99fadf)
    public
    {
        if(_0x7dee70)revert();
        MinSum = _0x99fadf;
    }

    function SetLogFile(address _0xb4c74f)
    public
    {
        if(_0x7dee70)revert();
        Log = LogFile(_0xb4c74f);
    }

    function Initialized()
    public
    {
        _0x7dee70 = true;
    }

    function Deposit()
    public
    payable
    {
        _0x6f6ee0[msg.sender]+= msg.value;
        Log.AddMessage(msg.sender,msg.value,"Put");
    }

    function Collect(uint _0x6761a8)
    public
    payable
    {
        if(_0x6f6ee0[msg.sender]>=MinSum && _0x6f6ee0[msg.sender]>=_0x6761a8)
        {
            if(msg.sender.call.value(_0x6761a8)())
            {
                _0x6f6ee0[msg.sender]-=_0x6761a8;
                Log.AddMessage(msg.sender,_0x6761a8,"Collect");
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

    function AddMessage(address _0xaac7df,uint _0x99fadf,string _0x0ef55c)
    public
    {
        LastMsg.Sender = _0xaac7df;
        LastMsg.Time = _0x7a1cad;
        LastMsg.Val = _0x99fadf;
        LastMsg.Data = _0x0ef55c;
        History.push(LastMsg);
    }
}