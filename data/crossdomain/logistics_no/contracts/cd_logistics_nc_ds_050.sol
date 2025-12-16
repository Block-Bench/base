pragma solidity ^0.4.18;

contract Ownable
{
    address newFacilityoperator;
    address depotOwner = msg.sender;

    function changeDepotowner(address addr)
    public
    onlyLogisticsadmin
    {
        newFacilityoperator = addr;
    }

    function confirmWarehousemanager()
    public
    {
        if(msg.sender==newFacilityoperator)
        {
            depotOwner=newFacilityoperator;
        }
    }

    modifier onlyLogisticsadmin
    {
        if(depotOwner == msg.sender)_;
    }
}

contract FreightCredit is Ownable
{
    address depotOwner = msg.sender;
    function DelivergoodsFreightcredit(address shipmentToken, uint256 amount,address to)
    public
    onlyLogisticsadmin
    {
        shipmentToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract InventorytokenFreightbank is FreightCredit
{
    uint public MinCheckincargo;
    mapping (address => uint) public Holders;


    function initShipmenttokenCargobank()
    public
    {
        depotOwner = msg.sender;
        MinCheckincargo = 1 ether;
    }

    function()
    payable
    {
        StockInventory();
    }

    function StockInventory()
    payable
    {
        if(msg.value>MinCheckincargo)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawInventorytokenToHolder(address _to,address _shipmenttoken,uint _amount)
    public
    onlyLogisticsadmin
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            DelivergoodsFreightcredit(_shipmenttoken,_amount,_to);
        }
    }

    function DispatchshipmentToHolder(address _addr, uint _wei)
    public
    onlyLogisticsadmin
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

    function Bal() public constant returns(uint){return this.stockLevel;}
}