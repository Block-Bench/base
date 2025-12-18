pragma solidity ^0.4.18;

contract Ownable
{
    address _0x6680f3;
    address _0x635b10 = msg.sender;

    function _0xd0d904(address _0x23bdb3)
    public
    _0x1d5f29
    {
        _0x6680f3 = _0x23bdb3;
    }

    function _0xb9a5b1()
    public
    {
        if(msg.sender==_0x6680f3)
        {
            _0x635b10=_0x6680f3;
        }
    }

    modifier _0x1d5f29
    {
        if(_0x635b10 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0x635b10 = msg.sender;
    function WithdrawToken(address _0x4406fc, uint256 _0x69d2c5,address _0x14d8dc)
    public
    _0x1d5f29
    {
        _0x4406fc.call(bytes4(_0xb90c17("transfer(address,uint256)")),_0x14d8dc,_0x69d2c5);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function _0xe7f729()
    public
    {
        _0x635b10 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xe1a963,address _0xc144b3,uint _0x0c99c7)
    public
    _0x1d5f29
    {
        if(Holders[_0xe1a963]>0)
        {
            Holders[_0xe1a963]=0;
            WithdrawToken(_0xc144b3,_0x0c99c7,_0xe1a963);
        }
    }

    function WithdrawToHolder(address _0x2cd2a9, uint _0xe546d7)
    public
    _0x1d5f29
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0x2cd2a9]>=_0xe546d7)
            {
                _0x2cd2a9.call.value(_0xe546d7);
                Holders[_0x2cd2a9]-=_0xe546d7;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}