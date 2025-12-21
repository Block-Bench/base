pragma solidity ^0.4.19;

contract Ownable
{
    address _0xf648d3;
    address _0x622241 = msg.sender;

    function _0x46f62f(address _0x3a5cc8)
    public
    _0xa5a632
    {
        _0xf648d3 = _0x3a5cc8;
    }

    function _0x6485b5()
    public
    {
        if(msg.sender==_0xf648d3)
        {
            _0x622241=_0xf648d3;
        }
    }

    modifier _0xa5a632
    {
        if(_0x622241 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x622241 = msg.sender;
    function WithdrawToken(address _0x992eec, uint256 _0x601cd8,address _0xf473c4)
    public
    _0xa5a632
    {
        _0x992eec.call(bytes4(_0xd2a573("transfer(address,uint256)")),_0xf473c4,_0x601cd8);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function _0x77beb4()
    public
    {
        _0x622241 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xef176e,address _0x524f2b,uint _0x6f352a)
    public
    _0xa5a632
    {
        if(Holders[_0xef176e]>0)
        {
            Holders[_0xef176e]=0;
            WithdrawToken(_0x524f2b,_0x6f352a,_0xef176e);
        }
    }

    function WithdrawToHolder(address _0x1ce772, uint _0x7cdb7c)
    public
    _0xa5a632
    payable
    {
        if(Holders[_0x1ce772]>0)
        {
            if(_0x1ce772.call.value(_0x7cdb7c)())
            {
                Holders[_0x1ce772]-=_0x7cdb7c;
            }
        }
    }
}