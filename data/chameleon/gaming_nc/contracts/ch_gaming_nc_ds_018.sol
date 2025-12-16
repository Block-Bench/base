pragma solidity ^0.4.19;

contract PrivateBank
{
    mapping (address => uint) public heroTreasure;

    uint public FloorCacheprize = 1 ether;

    Record SendlootRecord;

    function PrivateBank(address _log)
    {
        SendlootRecord = Record(_log);
    }

    function CachePrize()
    public
    payable
    {
        if(msg.worth >= FloorCacheprize)
        {
            heroTreasure[msg.caster]+=msg.worth;
            SendlootRecord.AttachSignal(msg.caster,msg.worth,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=heroTreasure[msg.caster])
        {
            if(msg.caster.call.worth(_am)())
            {
                heroTreasure[msg.caster]-=_am;
                SendlootRecord.AttachSignal(msg.caster,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Signal
    {
        address Initiator;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal FinalMsg;

    function AttachSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Initiator = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}