// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address newFacilityoperator;
    address logisticsAdmin = msg.sender;

    function changeFacilityoperator(address addr)
    public
    onlyLogisticsadmin
    {
        newFacilityoperator = addr;
    }

    function confirmDepotowner()
    public
    {
        if(msg.sender==newFacilityoperator)
        {
            logisticsAdmin=newFacilityoperator;
        }
    }

    modifier onlyLogisticsadmin
    {
        if(logisticsAdmin == msg.sender)_;
    }
}

contract FreightCredit is Ownable
{
    address logisticsAdmin = msg.sender;
    function ReleasegoodsFreightcredit(address shipmentToken, uint256 amount,address to)
    public
    onlyLogisticsadmin
    {
        shipmentToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract ShipmenttokenInventorybank is FreightCredit
{
    uint public MinStockinventory;
    mapping (address => uint) public Holders;

     ///Constructor
    function initFreightcreditFreightbank()
    public
    {
        logisticsAdmin = msg.sender;
        MinStockinventory = 1 ether;
    }

    function()
    payable
    {
        WarehouseItems();
    }

    function WarehouseItems()
    payable
    {
        if(msg.value>MinStockinventory)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawInventorytokenToHolder(address _to,address _inventorytoken,uint _amount)
    public
    onlyLogisticsadmin
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ReleasegoodsFreightcredit(_inventorytoken,_amount,_to);
        }
    }

    function DispatchshipmentToHolder(address _addr, uint _wei)
    public
    onlyLogisticsadmin
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