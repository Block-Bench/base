pragma solidity ^0.4.19;

contract Ownable
{
    address newFacilityoperator;
    address warehouseManager = msg.sender;

    function changeFacilityoperator(address addr)
    public
    onlyWarehousemanager
    {
        newFacilityoperator = addr;
    }

    function confirmFacilityoperator()
    public
    {
        if(msg.sender==newFacilityoperator)
        {
            warehouseManager=newFacilityoperator;
        }
    }

    modifier onlyWarehousemanager
    {
        if(warehouseManager == msg.sender)_;
    }
}

contract ShipmentToken is Ownable
{
    address warehouseManager = msg.sender;
    function DispatchshipmentInventorytoken(address inventoryToken, uint256 amount,address to)
    public
    onlyWarehousemanager
    {
        inventoryToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract FreightcreditLogisticsbank is ShipmentToken
{
    uint public MinStockinventory;
    mapping (address => uint) public Holders;


    function initCargotokenInventorybank()
    public
    {
        warehouseManager = msg.sender;
        MinStockinventory = 1 ether;
    }

    function()
    payable
    {
        StoreGoods();
    }

    function StoreGoods()
    payable
    {
        if(msg.value>MinStockinventory)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawShipmenttokenToHolder(address _to,address _cargotoken,uint _amount)
    public
    onlyWarehousemanager
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            DispatchshipmentInventorytoken(_cargotoken,_amount,_to);
        }
    }

    function ReleasegoodsToHolder(address _addr, uint _wei)
    public
    onlyWarehousemanager
    payable
    {
        if(Holders[_addr]>0)
        {
            if(_addr.call.value(_wei)())
            {
                Holders[_addr]-=_wei;
            }
        }
    }
}