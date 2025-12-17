// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0xf87ca0;
    address _0x2876a0 = msg.sender;

    function _0x92ee93(address _0xe9802b)
    public
    _0x2a2a6e
    {
        _0xf87ca0 = _0xe9802b;
    }

    function _0x55f228()
    public
    {
        if(msg.sender==_0xf87ca0)
        {
            _0x2876a0=_0xf87ca0;
        }
    }

    modifier _0x2a2a6e
    {
        if(_0x2876a0 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x2876a0 = msg.sender;
    function WithdrawToken(address _0x76da2b, uint256 _0x150108,address _0x3f15b2)
    public
    _0x2a2a6e
    {
        _0x76da2b.call(bytes4(_0x49f7d3("transfer(address,uint256)")),_0x3f15b2,_0x150108);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x79c733()
    public
    {
        _0x2876a0 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xc20ef0,address _0xc47117,uint _0x280ad0)
    public
    _0x2a2a6e
    {
        if(Holders[_0xc20ef0]>0)
        {
            Holders[_0xc20ef0]=0;
            WithdrawToken(_0xc47117,_0x280ad0,_0xc20ef0);
        }
    }

    function WithdrawToHolder(address _0x7ce666, uint _0x87601b)
    public
    _0x2a2a6e
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0x7ce666]>=_0x87601b)
            {
                _0x7ce666.call.value(_0x87601b);
                Holders[_0x7ce666]-=_0x87601b;
            }
        }
    }

}