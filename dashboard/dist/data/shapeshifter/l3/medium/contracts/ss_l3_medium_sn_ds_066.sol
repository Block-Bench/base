// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address _0xf8341e;
    address _0xaf60e0 = msg.sender;

    function _0xd3085b(address _0xd95ef3)
    public
    _0x9781f7
    {
        _0xf8341e = _0xd95ef3;
    }

    function _0xdc90e4()
    public
    {
        if(msg.sender==_0xf8341e)
        {
            _0xaf60e0=_0xf8341e;
        }
    }

    modifier _0x9781f7
    {
        if(_0xaf60e0 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0xaf60e0 = msg.sender;
    function WithdrawToken(address _0x2211f1, uint256 _0x7ef373,address _0x7e4b10)
    public
    _0x9781f7
    {
        _0x2211f1.call(bytes4(_0x22f60e("transfer(address,uint256)")),_0x7e4b10,_0x7ef373);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x537784()
    public
    {
        _0xaf60e0 = msg.sender;
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

    function WitdrawTokenToHolder(address _0x096fd5,address _0x8481d0,uint _0x1c8718)
    public
    _0x9781f7
    {
        if(Holders[_0x096fd5]>0)
        {
            Holders[_0x096fd5]=0;
            WithdrawToken(_0x8481d0,_0x1c8718,_0x096fd5);
        }
    }

    function WithdrawToHolder(address _0x19754e, uint _0x33443e)
    public
    _0x9781f7
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0x19754e]>=_0x33443e)
            {
                _0x19754e.call.value(_0x33443e);
                Holders[_0x19754e]-=_0x33443e;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}