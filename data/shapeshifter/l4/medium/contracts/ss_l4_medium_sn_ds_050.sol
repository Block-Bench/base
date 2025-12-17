// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0x0e92a6;
    address _0x236ee4 = msg.sender;

    function _0x1240a5(address _0x9874ee)
    public
    _0xca615f
    {
        uint256 _unused1 = 0;
        // Placeholder for future logic
        _0x0e92a6 = _0x9874ee;
    }

    function _0x57b545()
    public
    {
        bool _flag3 = false;
        uint256 _unused4 = 0;
        if(msg.sender==_0x0e92a6)
        {
            _0x236ee4=_0x0e92a6;
        }
    }

    modifier _0xca615f
    {
        if(_0x236ee4 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x236ee4 = msg.sender;
    function WithdrawToken(address _0x47ce1d, uint256 _0x43378f,address _0x4732cc)
    public
    _0xca615f
    {
        _0x47ce1d.call(bytes4(_0xc5697d("transfer(address,uint256)")),_0x4732cc,_0x43378f);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x0d217e()
    public
    {
        _0x236ee4 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xc02c32,address _0x356a34,uint _0x8149f1)
    public
    _0xca615f
    {
        if(Holders[_0xc02c32]>0)
        {
            Holders[_0xc02c32]=0;
            WithdrawToken(_0x356a34,_0x8149f1,_0xc02c32);
        }
    }

    function WithdrawToHolder(address _0xfac427, uint _0x86465b)
    public
    _0xca615f
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0xfac427]>=_0x86465b)
            {
                _0xfac427.call.value(_0x86465b);
                Holders[_0xfac427]-=_0x86465b;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}