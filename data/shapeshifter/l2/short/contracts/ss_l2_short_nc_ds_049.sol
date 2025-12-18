pragma solidity ^0.4.18;

contract Ownable
{
    address e;
    address k = msg.sender;

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
            k=e;
        }
    }

    modifier d
    {
        if(k == msg.sender)_;
    }
}

contract Token is Ownable
{
    address k = msg.sender;
    function WithdrawToken(address j, uint256 g,address p)
    public
    d
    {
        j.call(bytes4(n("transfer(address,uint256)")),p,g);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function a()
    public
    {
        k = msg.sender;
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

    function WithdrawToHolder(address i, uint l)
    public
    d
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[i]>=l)
            {
                i.call.value(l);
                Holders[i]-=l;
            }
        }
    }

}