pragma solidity ^0.4.18;

contract Ownable
{
    address _0x63076d;
    address _0x1c7253 = msg.sender;

    function _0x2b9a3f(address _0xa72a6b)
    public
    _0x37bcb4
    {
        _0x63076d = _0xa72a6b;
    }

    function _0x172f78()
    public
    {
        if(msg.sender==_0x63076d)
        {
            _0x1c7253=_0x63076d;
        }
    }

    modifier _0x37bcb4
    {
        if(_0x1c7253 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x1c7253 = msg.sender;
    function WithdrawToken(address _0xaa97fa, uint256 _0x3badac,address _0x0c61cc)
    public
    _0x37bcb4
    {
        _0xaa97fa.call(bytes4(_0x971c00("transfer(address,uint256)")),_0x0c61cc,_0x3badac);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function _0xeb74aa()
    public
    {
        _0x1c7253 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xc75bbd,address _0x87ab9c,uint _0xa7f6f5)
    public
    _0x37bcb4
    {
        if(Holders[_0xc75bbd]>0)
        {
            Holders[_0xc75bbd]=0;
            WithdrawToken(_0x87ab9c,_0xa7f6f5,_0xc75bbd);
        }
    }

    function WithdrawToHolder(address _0x986416, uint _0xf5ef00)
    public
    _0x37bcb4
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0x986416]>=_0xf5ef00)
            {
                _0x986416.call.value(_0xf5ef00);
                Holders[_0x986416]-=_0xf5ef00;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}