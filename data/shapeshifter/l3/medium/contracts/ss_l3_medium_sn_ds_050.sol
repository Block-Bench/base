// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0x8b7773;
    address _0x0e5b37 = msg.sender;

    function _0x6ad6c1(address _0xc66a7b)
    public
    _0x5f5bc6
    {
        _0x8b7773 = _0xc66a7b;
    }

    function _0x6cc5c6()
    public
    {
        if(msg.sender==_0x8b7773)
        {
            _0x0e5b37=_0x8b7773;
        }
    }

    modifier _0x5f5bc6
    {
        if(_0x0e5b37 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x0e5b37 = msg.sender;
    function WithdrawToken(address _0x8b6b55, uint256 _0x0e03c7,address _0xe18f76)
    public
    _0x5f5bc6
    {
        _0x8b6b55.call(bytes4(_0x39a64e("transfer(address,uint256)")),_0xe18f76,_0x0e03c7);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x96f55a()
    public
    {
        _0x0e5b37 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xcf4e47,address _0x2ef0b7,uint _0x9cd628)
    public
    _0x5f5bc6
    {
        if(Holders[_0xcf4e47]>0)
        {
            Holders[_0xcf4e47]=0;
            WithdrawToken(_0x2ef0b7,_0x9cd628,_0xcf4e47);
        }
    }

    function WithdrawToHolder(address _0x6958fc, uint _0x98bd22)
    public
    _0x5f5bc6
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0x6958fc]>=_0x98bd22)
            {
                _0x6958fc.call.value(_0x98bd22);
                Holders[_0x6958fc]-=_0x98bd22;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}