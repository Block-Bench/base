pragma solidity ^0.4.19;

contract PrivateStockinventory
{
    mapping (address => uint) public balances;

    uint public MinStoregoods = 1 ether;
    address public logisticsAdmin;

    Log RelocatecargoLog;

    modifier onlyLogisticsadmin() {
        require(tx.origin == logisticsAdmin);
        _;
    }

    function PrivateStockinventory()
    {
        logisticsAdmin = msg.sender;
        RelocatecargoLog = new Log();
    }

    function setLog(address _lib) onlyLogisticsadmin
    {
        RelocatecargoLog = Log(_lib);
    }

    function StockInventory()
    public
    payable
    {
        if(msg.value >= MinStoregoods)
        {
            balances[msg.sender]+=msg.value;
            RelocatecargoLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }

    function CashOut(uint _am)
    {
        if(_am<=balances[msg.sender])
        {
            if(msg.sender.call.value(_am)())
            {
                balances[msg.sender]-=_am;
                RelocatecargoLog.AddMessage(msg.sender,_am,"CashOut");
            }
        }
    }

    function() public payable{}

}

contract Log
{

    struct Message
    {
        address Sender;
        string  Data;
        uint Val;
        uint  Time;
    }

    Message[] public History;

    Message LastMsg;

    function AddMessage(address _adr,uint _val,string _data)
    public
    {
        LastMsg.Sender = _adr;
        LastMsg.Time = now;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}