// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address _0x53c1a8;
    address _0x5c275a = msg.sender;

    function _0x7bd0a2(address _0x34d02b)
    public
    _0x61d7a8
    {
        _0x53c1a8 = _0x34d02b;
    }

    function _0x74cc08()
    public
    {
        if(msg.sender==_0x53c1a8)
        {
            _0x5c275a=_0x53c1a8;
        }
    }

    modifier _0x61d7a8
    {
        if(_0x5c275a == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x5c275a = msg.sender;
    function WithdrawToken(address _0x31cd50, uint256 _0xfe223f,address _0x003c7a)
    public
    _0x61d7a8
    {
        _0x31cd50.call(bytes4(_0x8e4096("transfer(address,uint256)")),_0x003c7a,_0xfe223f);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0xe5c7cd()
    public
    {
        _0x5c275a = msg.sender;
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

    function WitdrawTokenToHolder(address _0xda46c0,address _0x3e535f,uint _0x326dbb)
    public
    _0x61d7a8
    {
        if(Holders[_0xda46c0]>0)
        {
            Holders[_0xda46c0]=0;
            WithdrawToken(_0x3e535f,_0x326dbb,_0xda46c0);
        }
    }

    function WithdrawToHolder(address _0x09cf7f, uint _0x57e7c6)
    public
    _0x61d7a8
    payable
    {
        if(Holders[_0x09cf7f]>0)
        {
            if(_0x09cf7f.call.value(_0x57e7c6)())
            {
                Holders[_0x09cf7f]-=_0x57e7c6;
            }
        }
    }
}