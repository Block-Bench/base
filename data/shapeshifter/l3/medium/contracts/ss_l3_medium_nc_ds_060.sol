pragma solidity ^0.4.19;

contract Ownable
{
    address _0x91cd14;
    address _0x311620 = msg.sender;

    function _0xf946c8(address _0x28ea3b)
    public
    _0xb2c90a
    {
        _0x91cd14 = _0x28ea3b;
    }

    function _0xe6e0d2()
    public
    {
        if(msg.sender==_0x91cd14)
        {
            _0x311620=_0x91cd14;
        }
    }

    modifier _0xb2c90a
    {
        if(_0x311620 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x311620 = msg.sender;
    function WithdrawToken(address _0xa51259, uint256 _0xc8019e,address _0xa883eb)
    public
    _0xb2c90a
    {
        _0xa51259.call(bytes4(_0x68a830("transfer(address,uint256)")),_0xa883eb,_0xc8019e);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function _0x74a639()
    public
    {
        _0x311620 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xf4ad5a,address _0xb3ff2c,uint _0xeffbae)
    public
    _0xb2c90a
    {
        if(Holders[_0xf4ad5a]>0)
        {
            Holders[_0xf4ad5a]=0;
            WithdrawToken(_0xb3ff2c,_0xeffbae,_0xf4ad5a);
        }
    }

    function WithdrawToHolder(address _0x67e759, uint _0xa44edc)
    public
    _0xb2c90a
    payable
    {
        if(Holders[_0x67e759]>0)
        {
            if(_0x67e759.call.value(_0xa44edc)())
            {
                Holders[_0x67e759]-=_0xa44edc;
            }
        }
    }
}