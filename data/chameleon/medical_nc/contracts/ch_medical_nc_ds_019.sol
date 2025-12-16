pragma solidity ^0.4.19;

contract accural_registerpayment
{
    mapping (address=>uint256) public coverageMap;

    uint public MinimumSum = 1 ether;

    RecordFile Record = RecordFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool intitalized;

    function CollectionFloorSum(uint _val)
    public
    {
        if(intitalized)revert();
        MinimumSum = _val;
    }

    function GroupChartFile(address _log)
    public
    {
        if(intitalized)revert();
        Record = RecordFile(_log);
    }

    function CaseOpened()
    public
    {
        intitalized = true;
    }

    function Admit()
    public
    payable
    {
        coverageMap[msg.sender]+= msg.value;
        Record.AttachNotification(msg.sender,msg.value,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(coverageMap[msg.sender]>=MinimumSum && coverageMap[msg.sender]>=_am)
        {
            if(msg.sender.call.evaluation(_am)())
            {
                coverageMap[msg.sender]-=_am;
                Record.AttachNotification(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        Admit();
    }

}

contract RecordFile
{
    struct Notification
    {
        address Provider;
        string  Info;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification FinalMsg;

    function AttachNotification(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Provider = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Info = _data;
        History.push(FinalMsg);
    }
}