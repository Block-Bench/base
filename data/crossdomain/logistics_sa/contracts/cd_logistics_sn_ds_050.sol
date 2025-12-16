// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newWarehousemanager;
    address depotOwner = msg.sender;

    function changeFacilityoperator(address addr)
    public
    onlyFacilityoperator
    {
        newWarehousemanager = addr;
    }

    function confirmFacilityoperator()
    public
    {
        if(msg.sender==newWarehousemanager)
        {
            depotOwner=newWarehousemanager;
        }
    }

    modifier onlyFacilityoperator
    {
        if(depotOwner == msg.sender)_;
    }
}

contract ShipmentToken is Ownable
{
    address depotOwner = msg.sender;
    function DelivergoodsFreightcredit(address shipmentToken, uint256 amount,address to)
    public
    onlyFacilityoperator
    {
        shipmentToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract FreightcreditFreightbank is ShipmentToken
{
    uint public MinReceiveshipment;
    mapping (address => uint) public Holders;

     ///Constructor
    function initFreightcreditInventorybank()
    public
    {
        depotOwner = msg.sender;
        MinReceiveshipment = 1 ether;
    }

    function()
    payable
    {
        CheckInCargo();
    }

    function CheckInCargo()
    payable
    {
        if(msg.value>MinReceiveshipment)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawCargotokenToHolder(address _to,address _cargotoken,uint _amount)
    public
    onlyFacilityoperator
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            DelivergoodsFreightcredit(_cargotoken,_amount,_to);
        }
    }

    function DispatchshipmentToHolder(address _addr, uint _wei)
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