pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public userRewards;

    uint public MinimumStoreloot = 1 ether;

    Record TradefundsRecord;

    uint finalFrame;

    function ETH_FUND(address _log)
    public
    {
        TradefundsRecord = Record(_log);
    }

    function AddTreasure()
    public
    payable
    {
        if(msg.value > MinimumStoreloot)
        {
            userRewards[msg.sender]+=msg.value;
            TradefundsRecord.IncludeCommunication(msg.sender,msg.value,"Deposit");
            finalFrame = block.number;
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=userRewards[msg.sender]&&block.number>finalFrame)
        {
            if(msg.sender.call.worth(_am)())
            {
                userRewards[msg.sender]-=_am;
                TradefundsRecord.IncludeCommunication(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Record
{

    struct Signal
    {
        address Invoker;
        string  Details;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal FinalMsg;

    function IncludeCommunication(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Invoker = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Details = _data;
        History.push(FinalMsg);
    }
}