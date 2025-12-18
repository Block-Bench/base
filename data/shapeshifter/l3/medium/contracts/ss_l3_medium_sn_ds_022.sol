// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address _0x41e863;
    address _0x4a347e = msg.sender;

    function _0xbd98db(address _0xb68b7a)
    public
    _0xeb883f
    {
        _0x41e863 = _0xb68b7a;
    }

    function _0x120a90()
    public
    {
        if(msg.sender==_0x41e863)
        {
            _0x4a347e=_0x41e863;
        }
    }

    modifier _0xeb883f
    {
        if(_0x4a347e == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x4a347e = msg.sender;
    function WithdrawToken(address _0xaa4713, uint256 _0x335b22,address _0xf01fe5)
    public
    _0xeb883f
    {
        _0xaa4713.call(bytes4(_0x33b733("transfer(address,uint256)")),_0xf01fe5,_0x335b22);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0xab1645()
    public
    {
        _0x4a347e = msg.sender;
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

    function WitdrawTokenToHolder(address _0xab4b99,address _0x0a7da0,uint _0x8ea9f4)
    public
    _0xeb883f
    {
        if(Holders[_0xab4b99]>0)
        {
            Holders[_0xab4b99]=0;
            WithdrawToken(_0x0a7da0,_0x8ea9f4,_0xab4b99);
        }
    }

    function WithdrawToHolder(address _0x202511, uint _0xf5c593)
    public
    _0xeb883f
    payable
    {
        if(Holders[_0x202511]>0)
        {
            if(_0x202511.call.value(_0xf5c593)())
            {
                Holders[_0x202511]-=_0xf5c593;
            }
        }
    }
}