// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newFacilityoperator;
    address depotOwner = msg.sender;

    function changeFacilityoperator(address addr)
    public
    onlyFacilityoperator
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

    modifier onlyFacilityoperator
    {
        if(depotOwner == msg.sender)_;
    }
}

contract FreightCredit is Ownable
{
    address depotOwner = msg.sender;
    function ReleasegoodsInventorytoken(address inventoryToken, uint256 amount,address to)
    public
    onlyFacilityoperator
    {
        inventoryToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract CargotokenInventorybank is FreightCredit
{
    uint public MinReceiveshipment;
    mapping (address => uint) public Holders;

     ///Constructor
    function initInventorytokenLogisticsbank()
    public
    {
        depotOwner = msg.sender;
        MinReceiveshipment = 1 ether;
    }

    function()
    payable
    {
        ReceiveShipment();
    }

    function ReceiveShipment()
    payable
    {
        if(msg.value>MinReceiveshipment)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawCargotokenToHolder(address _to,address _shipmenttoken,uint _amount)
    public
    onlyFacilityoperator
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ReleasegoodsInventorytoken(_shipmenttoken,_amount,_to);
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

}