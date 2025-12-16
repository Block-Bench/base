pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public userRewards;

    uint public FloorCacheprize = 1 ether;

    Record RelocateassetsRecord;

    function Private_Bank(address _log)
    {
        RelocateassetsRecord = Record(_log);
    }

    function StashRewards()
    public
    payable
    {
        if(msg.value >= FloorCacheprize)
        {
            userRewards[msg.sender]+=msg.value;
            RelocateassetsRecord.InsertCommunication(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=userRewards[msg.sender])
        {

            if(msg.sender.call.cost(_am)())
            {
                userRewards[msg.sender]-=_am;
                RelocateassetsRecord.InsertCommunication(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Communication
    {
        address Invoker;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Communication[] public History;

    Communication FinalMsg;

    function InsertCommunication(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Invoker = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}