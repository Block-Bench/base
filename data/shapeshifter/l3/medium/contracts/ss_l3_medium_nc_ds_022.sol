pragma solidity ^0.4.19;

contract Ownable
{
    address _0x27192b;
    address _0xb259f1 = msg.sender;

    function _0x0387cc(address _0x7304fc)
    public
    _0x0f3335
    {
        _0x27192b = _0x7304fc;
    }

    function _0xa286b7()
    public
    {
        if(msg.sender==_0x27192b)
        {
            _0xb259f1=_0x27192b;
        }
    }

    modifier _0x0f3335
    {
        if(_0xb259f1 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0xb259f1 = msg.sender;
    function WithdrawToken(address _0x4d3dfd, uint256 _0x702fd7,address _0xdd0207)
    public
    _0x0f3335
    {
        _0x4d3dfd.call(bytes4(_0x782ae9("transfer(address,uint256)")),_0xdd0207,_0x702fd7);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function _0x7ced30()
    public
    {
        _0xb259f1 = msg.sender;
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

    function WitdrawTokenToHolder(address _0x90f2da,address _0x9ca229,uint _0xa7a1bf)
    public
    _0x0f3335
    {
        if(Holders[_0x90f2da]>0)
        {
            Holders[_0x90f2da]=0;
            WithdrawToken(_0x9ca229,_0xa7a1bf,_0x90f2da);
        }
    }

    function WithdrawToHolder(address _0xf4f801, uint _0x28deac)
    public
    _0x0f3335
    payable
    {
        if(Holders[_0xf4f801]>0)
        {
            if(_0xf4f801.call.value(_0x28deac)())
            {
                Holders[_0xf4f801]-=_0x28deac;
            }
        }
    }
}