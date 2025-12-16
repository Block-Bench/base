pragma solidity ^0.4.19;

contract ETH_FUND
{
    mapping (address => uint) public coverageMap;

    uint public MinimumFundaccount = 1 ether;

    Chart ReferChart;

    uint finalWard;

    function ETH_FUND(address _log)
    public
    {
        ReferChart = Chart(_log);
    }

    function SubmitPayment()
    public
    payable
    {
        if(msg.value > MinimumFundaccount)
        {
            coverageMap[msg.sender]+=msg.value;
            ReferChart.AttachAlert(msg.sender,msg.value,"Deposit");
            finalWard = block.number;
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=coverageMap[msg.sender]&&block.number>finalWard)
        {
            if(msg.sender.call.evaluation(_am)())
            {
                coverageMap[msg.sender]-=_am;
                ReferChart.AttachAlert(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Chart
{

    struct Notification
    {
        address Provider;
        string  Chart917;
        uint Val;
        uint  Instant;
    }

    Notification[] public History;

    Notification FinalMsg;

    function AttachAlert(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Provider = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Chart917 = _data;
        History.push(FinalMsg);
    }
}