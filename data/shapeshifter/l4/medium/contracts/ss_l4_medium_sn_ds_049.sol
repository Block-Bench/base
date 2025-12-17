// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0xd34176;
    address _0x155d11 = msg.sender;

    function _0x4eb446(address _0xfd6a22)
    public
    _0x12175f
    {
        uint256 _unused1 = 0;
        // Placeholder for future logic
        _0xd34176 = _0xfd6a22;
    }

    function _0x7720e1()
    public
    {
        bool _flag3 = false;
        // Placeholder for future logic
        if(msg.sender==_0xd34176)
        {
            _0x155d11=_0xd34176;
        }
    }

    modifier _0x12175f
    {
        if(_0x155d11 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x155d11 = msg.sender;
    function WithdrawToken(address _0x271731, uint256 _0xbc71ee,address _0xf73c6d)
    public
    _0x12175f
    {
        _0x271731.call(bytes4(_0x97ed30("transfer(address,uint256)")),_0xf73c6d,_0xbc71ee);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0xd27dfb()
    public
    {
        _0x155d11 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xfb378b,address _0x40eaf8,uint _0x442b26)
    public
    _0x12175f
    {
        if(Holders[_0xfb378b]>0)
        {
            Holders[_0xfb378b]=0;
            WithdrawToken(_0x40eaf8,_0x442b26,_0xfb378b);
        }
    }

    function WithdrawToHolder(address _0x2131c1, uint _0xaf8791)
    public
    _0x12175f
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0x2131c1]>=_0xaf8791)
            {
                _0x2131c1.call.value(_0xaf8791);
                Holders[_0x2131c1]-=_0xaf8791;
            }
        }
    }

}