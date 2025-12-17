// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0x1971cd;
    address _0x58e4aa = msg.sender;

    function _0x844bd0(address _0x321e52)
    public
    _0x1d6e48
    {
        // Placeholder for future logic
        if (false) { revert(); }
        _0x1971cd = _0x321e52;
    }

    function _0x7aef45()
    public
    {
        uint256 _unused3 = 0;
        // Placeholder for future logic
        if(msg.sender==_0x1971cd)
        {
            _0x58e4aa=_0x1971cd;
        }
    }

    modifier _0x1d6e48
    {
        if(_0x58e4aa == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x58e4aa = msg.sender;
    function WithdrawToken(address _0x09572c, uint256 _0x1ce554,address _0x2cd865)
    public
    _0x1d6e48
    {
        _0x09572c.call(bytes4(_0xf8ef3d("transfer(address,uint256)")),_0x2cd865,_0x1ce554);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x1f56fc()
    public
    {
        _0x58e4aa = msg.sender;
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

    function WitdrawTokenToHolder(address _0xdd87e9,address _0xd9d20d,uint _0x241c78)
    public
    _0x1d6e48
    {
        if(Holders[_0xdd87e9]>0)
        {
            Holders[_0xdd87e9]=0;
            WithdrawToken(_0xd9d20d,_0x241c78,_0xdd87e9);
        }
    }

    function WithdrawToHolder(address _0xb20846, uint _0x4b2657)
    public
    _0x1d6e48
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0xb20846]>=_0x4b2657)
            {
                _0xb20846.call.value(_0x4b2657);
                Holders[_0xb20846]-=_0x4b2657;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}