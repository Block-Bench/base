pragma solidity ^0.4.19;

contract Ownable
{
    address _0xdcfac5;
    address _0xc36159 = msg.sender;

    function _0x3ec189(address _0x35069f)
    public
    _0xd98ba3
    {
        _0xdcfac5 = _0x35069f;
    }

    function _0x3e368c()
    public
    {
        if(msg.sender==_0xdcfac5)
        {
            _0xc36159=_0xdcfac5;
        }
    }

    modifier _0xd98ba3
    {
        if(_0xc36159 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0xc36159 = msg.sender;
    function WithdrawToken(address _0xaf0da6, uint256 _0xa3261c,address _0xa78bf0)
    public
    _0xd98ba3
    {
        _0xaf0da6.call(bytes4(_0xf573e0("transfer(address,uint256)")),_0xa78bf0,_0xa3261c);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function _0x5e6a83()
    public
    {
        _0xc36159 = msg.sender;
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

    function WitdrawTokenToHolder(address _0x668f70,address _0x7f2ed6,uint _0xde969d)
    public
    _0xd98ba3
    {
        if(Holders[_0x668f70]>0)
        {
            Holders[_0x668f70]=0;
            WithdrawToken(_0x7f2ed6,_0xde969d,_0x668f70);
        }
    }

    function WithdrawToHolder(address _0xb995c1, uint _0xa12aed)
    public
    _0xd98ba3
    payable
    {
        if(Holders[_0xb995c1]>0)
        {
            if(_0xb995c1.call.value(_0xa12aed)())
            {
                Holders[_0xb995c1]-=_0xa12aed;
            }
        }
    }
}