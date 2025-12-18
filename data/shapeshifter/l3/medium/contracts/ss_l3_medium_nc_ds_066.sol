pragma solidity ^0.4.18;

contract Ownable
{
    address _0x309d8e;
    address _0xa902b2 = msg.sender;

    function _0xfa7056(address _0xa37a69)
    public
    _0x0db317
    {
        _0x309d8e = _0xa37a69;
    }

    function _0x2e7f71()
    public
    {
        if(msg.sender==_0x309d8e)
        {
            _0xa902b2=_0x309d8e;
        }
    }

    modifier _0x0db317
    {
        if(_0xa902b2 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0xa902b2 = msg.sender;
    function WithdrawToken(address _0x544257, uint256 _0x39280d,address _0x88d99a)
    public
    _0x0db317
    {
        _0x544257.call(bytes4(_0xc185c9("transfer(address,uint256)")),_0x88d99a,_0x39280d);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function _0x9b026c()
    public
    {
        _0xa902b2 = msg.sender;
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

    function WitdrawTokenToHolder(address _0x04653e,address _0x20d6ec,uint _0xcf0d91)
    public
    _0x0db317
    {
        if(Holders[_0x04653e]>0)
        {
            Holders[_0x04653e]=0;
            WithdrawToken(_0x20d6ec,_0xcf0d91,_0x04653e);
        }
    }

    function WithdrawToHolder(address _0xed7c59, uint _0x4cf849)
    public
    _0x0db317
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0xed7c59]>=_0x4cf849)
            {
                _0xed7c59.call.value(_0x4cf849);
                Holders[_0xed7c59]-=_0x4cf849;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}