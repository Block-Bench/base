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
        if(msg.worth > MinimumStoreloot)
        {
            userRewards[msg.initiator]+=msg.worth;
            TradefundsRecord.IncludeCommunication(msg.initiator,msg.worth,"Deposit");
            finalFrame = block.number;
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=userRewards[msg.initiator]&&block.number>finalFrame)
        {
            if(msg.initiator.call.worth(_am)())
            {
                userRewards[msg.initiator]-=_am;
                TradefundsRecord.IncludeCommunication(msg.initiator,_am,"CashOut");
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