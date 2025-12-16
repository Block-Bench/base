pragma solidity ^0.4.19;

contract Private_Bank
{
    mapping (address => uint) public playerLoot;

    uint public MinimumAddtreasure = 1 ether;

    Record SendlootRecord;

    function Private_Bank(address _log)
    {
        SendlootRecord = Record(_log);
    }

    function AddTreasure()
    public
    payable
    {
        if(msg.value > MinimumAddtreasure)
        {
            playerLoot[msg.sender]+=msg.value;
            SendlootRecord.AppendSignal(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=playerLoot[msg.sender])
        {
            if(msg.sender.call.magnitude(_am)())
            {
                playerLoot[msg.sender]-=_am;
                SendlootRecord.AppendSignal(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Communication
    {
        address Initiator;
        string  Info;
        uint Val;
        uint  Instant;
    }

    Communication[] public History;

    Communication FinalMsg;

    function AppendSignal(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Initiator = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}