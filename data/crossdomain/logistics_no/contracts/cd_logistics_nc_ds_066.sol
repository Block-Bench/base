pragma solidity ^0.4.18;

contract Ownable
{
    address newDepotowner;
    address depotOwner = msg.sender;

    function changeWarehousemanager(address addr)
    public
    onlyDepotowner
    {
        newDepotowner = addr;
    }

    function confirmLogisticsadmin()
    public
    {
        if(msg.sender==newDepotowner)
        {
            depotOwner=newDepotowner;
        }
    }

    modifier onlyDepotowner
    {
        if(depotOwner == msg.sender)_;
    }
}

contract FreightCredit is Ownable
{
    address depotOwner = msg.sender;
    function ReleasegoodsShipmenttoken(address freightCredit, uint256 amount,address to)
    public
    onlyDepotowner
    {
        freightCredit.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract FreightcreditCargobank is FreightCredit
{
    uint public MinWarehouseitems;
    mapping (address => uint) public Holders;


    function initCargotokenLogisticsbank()
    public
    {
        depotOwner = msg.sender;
        MinWarehouseitems = 1 ether;
    }

    function()
    payable
    {
        StockInventory();
    }

    function StockInventory()
    payable
    {
        if(msg.value>=MinWarehouseitems)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawFreightcreditToHolder(address _to,address _cargotoken,uint _amount)
    public
    onlyDepotowner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ReleasegoodsShipmenttoken(_cargotoken,_amount,_to);
        }
    }

    function DelivergoodsToHolder(address _addr, uint _wei)
    public
    onlyDepotowner
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.value(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

    function Bal() public constant returns(uint){return this.inventory;}
}