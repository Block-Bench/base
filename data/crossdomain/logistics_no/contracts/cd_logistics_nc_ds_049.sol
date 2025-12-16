pragma solidity ^0.4.18;

contract Ownable
{
    address newLogisticsadmin;
    address warehouseManager = msg.sender;

    function changeWarehousemanager(address addr)
    public
    onlyDepotowner
    {
        newLogisticsadmin = addr;
    }

    function confirmDepotowner()
    public
    {
        if(msg.sender==newLogisticsadmin)
        {
            warehouseManager=newLogisticsadmin;
        }
    }

    modifier onlyDepotowner
    {
        if(warehouseManager == msg.sender)_;
    }
}

contract InventoryToken is Ownable
{
    address warehouseManager = msg.sender;
    function DispatchshipmentInventorytoken(address freightCredit, uint256 amount,address to)
    public
    onlyDepotowner
    {
        freightCredit.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract FreightcreditCargobank is InventoryToken
{
    uint public MinReceiveshipment;
    mapping (address => uint) public Holders;


    function initFreightcreditLogisticsbank()
    public
    {
        warehouseManager = msg.sender;
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

    function WitdrawInventorytokenToHolder(address _to,address _inventorytoken,uint _amount)
    public
    onlyDepotowner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            DispatchshipmentInventorytoken(_inventorytoken,_amount,_to);
        }
    }

    function DispatchshipmentToHolder(address _addr, uint _wei)
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

}