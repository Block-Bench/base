// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newLogisticsadmin;
    address logisticsAdmin = msg.sender;

    function changeLogisticsadmin(address addr)
    public
    onlyFacilityoperator
    {
        newLogisticsadmin = addr;
    }

    function confirmDepotowner()
    public
    {
        if(msg.sender==newLogisticsadmin)
        {
            logisticsAdmin=newLogisticsadmin;
        }
    }

    modifier onlyFacilityoperator
    {
        if(logisticsAdmin == msg.sender)_;
    }
}

contract FreightCredit is Ownable
{
    address logisticsAdmin = msg.sender;
    function DispatchshipmentInventorytoken(address shipmentToken, uint256 amount,address to)
    public
    onlyFacilityoperator
    {
        shipmentToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract InventorytokenFreightbank is FreightCredit
{
    uint public MinStoregoods;
    mapping (address => uint) public Holders;

     ///Constructor
    function initShipmenttokenInventorybank()
    public
    {
        logisticsAdmin = msg.sender;
        MinStoregoods = 1 ether;
    }

    function()
    payable
    {
        CheckInCargo();
    }

    function CheckInCargo()
    payable
    {
        if(msg.value>=MinStoregoods)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawFreightcreditToHolder(address _to,address _freightcredit,uint _amount)
    public
    onlyFacilityoperator
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            DispatchshipmentInventorytoken(_freightcredit,_amount,_to);
        }
    }

    function ReleasegoodsToHolder(address _addr, uint _wei)
    public
    onlyFacilityoperator
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

    function Bal() public constant returns(uint){return this.cargoCount;}
}