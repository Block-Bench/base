// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0x3f4ad7;
    address _0x0a02aa = msg.sender;

    function _0xae8e90(address _0x6f94f4)
    public
    _0xd58de8
    {
        _0x3f4ad7 = _0x6f94f4;
    }

    function _0x3efdb0()
    public
    {
        if(msg.sender==_0x3f4ad7)
        {
            _0x0a02aa=_0x3f4ad7;
        }
    }

    modifier _0xd58de8
    {
        if(_0x0a02aa == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x0a02aa = msg.sender;
    function WithdrawToken(address _0x072d2b, uint256 _0xd4708b,address _0x5b8db3)
    public
    _0xd58de8
    {
        _0x072d2b.call(bytes4(_0x502184("transfer(address,uint256)")),_0x5b8db3,_0xd4708b);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0xc20c4f()
    public
    {
        _0x0a02aa = msg.sender;
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
        if(msg.value>=MinDeposit)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawTokenToHolder(address _0x0b8d28,address _0xf51ad7,uint _0x530561)
    public
    _0xd58de8
    {
        if(Holders[_0x0b8d28]>0)
        {
            Holders[_0x0b8d28]=0;
            WithdrawToken(_0xf51ad7,_0x530561,_0x0b8d28);
        }
    }

    function WithdrawToHolder(address _0x54dcae, uint _0xd796d2)
    public
    _0xd58de8
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0x54dcae]>=_0xd796d2)
            {
                _0x54dcae.call.value(_0xd796d2);
                Holders[_0x54dcae]-=_0xd796d2;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}