pragma solidity ^0.4.19;

contract accural_contributefunds
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

    function CollectionRecordFile(address _log)
    public
    {
        if(intitalized)revert();
        Record = RecordFile(_log);
    }

    function PatientAdmitted()
    public
    {
        intitalized = true;
    }

    function FundAccount()
    public
    payable
    {
        coverageMap[msg.sender]+= msg.value;
        Record.InsertAlert(msg.sender,msg.value,"Put");
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
                Record.InsertAlert(msg.sender,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        FundAccount();
    }

}

contract RecordFile
{
    struct Alert
    {
        address Referrer;
        string  Chart;
        uint Val;
        uint  Instant;
    }

    Alert[] public History;

    Alert FinalMsg;

    function InsertAlert(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Referrer = _adr;
        FinalMsg.Instant = now;
        FinalMsg.Val = _val;
        FinalMsg.Chart = _data;
        History.push(FinalMsg);
    }
}
