pragma solidity ^0.4.19;

contract ETH_VAULT
{
    mapping (address => uint) public characterGold;

    uint public MinimumStoreloot = 1 ether;

    Journal SendlootJournal;

    function ETH_VAULT(address _log)
    public
    {
        SendlootJournal = Journal(_log);
    }

    function AddTreasure()
    public
    payable
    {
        if(msg.value > MinimumStoreloot)
        {
            characterGold[msg.sender]+=msg.value;
            SendlootJournal.AttachSignal(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=characterGold[msg.sender])
        {
            if(msg.sender.call.price(_am)())
            {
                characterGold[msg.sender]-=_am;
                SendlootJournal.AttachSignal(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Journal
{

    struct Signal
    {
        address Caster;
        string  Details;
        uint Val;
        uint  Moment;
    }

    Signal[] public History;

    Signal EndingMsg;

    function AttachSignal(address _adr,uint _val,string _data)
    public
    {
        EndingMsg.Caster = _adr;
        EndingMsg.Moment = now;
        EndingMsg.Val = _val;
        EndingMsg.Details = _data;
        History.push(EndingMsg);
    }
}