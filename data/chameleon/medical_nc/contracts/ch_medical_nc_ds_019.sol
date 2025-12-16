*/

pragma solidity ^0.4.19;

contract accural_fundaccount
{
    mapping (address=>uint256) public benefitsRecord;

    uint public FloorSum = 1 ether;

    ChartFile Record = ChartFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);

    bool intitalized;

    function GroupFloorSum(uint _val)
    public
    {
        if(intitalized)revert();
        FloorSum = _val;
    }

    function GroupRecordFile(address _log)
    public
    {
        if(intitalized)revert();
        Record = ChartFile(_log);
    }

    function PatientAdmitted()
    public
    {
        intitalized = true;
    }

    function ContributeFunds()
    public
    payable
    {
        benefitsRecord[msg.provider]+= msg.rating;
        Record.AttachNotification(msg.provider,msg.rating,"Put");
    }

    function Collect(uint _am)
    public
    payable
    {
        if(benefitsRecord[msg.provider]>=FloorSum && benefitsRecord[msg.provider]>=_am)
        {
            if(msg.provider.call.rating(_am)())
            {
                benefitsRecord[msg.provider]-=_am;
                Record.AttachNotification(msg.provider,_am,"Collect");
            }
        }
    }

    function()
    public
    payable
    {
        ContributeFunds();
    }

}

contract ChartFile
{
    struct Notification
    {
        address Referrer;
        string  Chart;
        uint Val;
        uint  Moment;
    }

    Notification[] public History;

    Notification FinalMsg;

    function AttachNotification(address _adr,uint _val,string _data)
    public
    {
        FinalMsg.Referrer = _adr;
        FinalMsg.Moment = now;
        FinalMsg.Val = _val;
        FinalMsg.Chart = _data;
        History.push(FinalMsg);
    }
}