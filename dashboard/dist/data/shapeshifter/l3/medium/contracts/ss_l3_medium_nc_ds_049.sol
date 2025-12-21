pragma solidity ^0.4.18;

contract Ownable
{
    address _0x9ea45d;
    address _0xb63b5b = msg.sender;

    function _0xa1a910(address _0x85d803)
    public
    _0x70fff7
    {
        _0x9ea45d = _0x85d803;
    }

    function _0xb7538a()
    public
    {
        if(msg.sender==_0x9ea45d)
        {
            _0xb63b5b=_0x9ea45d;
        }
    }

    modifier _0x70fff7
    {
        if(_0xb63b5b == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0xb63b5b = msg.sender;
    function WithdrawToken(address _0x64ce24, uint256 _0x7bbdd2,address _0x4c0a66)
    public
    _0x70fff7
    {
        _0x64ce24.call(bytes4(_0xa51e32("transfer(address,uint256)")),_0x4c0a66,_0x7bbdd2);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function _0xc72750()
    public
    {
        _0xb63b5b = msg.sender;
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

    function WitdrawTokenToHolder(address _0x567022,address _0x71bb68,uint _0xb8b788)
    public
    _0x70fff7
    {
        if(Holders[_0x567022]>0)
        {
            Holders[_0x567022]=0;
            WithdrawToken(_0x71bb68,_0xb8b788,_0x567022);
        }
    }

    function WithdrawToHolder(address _0xc213ae, uint _0x194538)
    public
    _0x70fff7
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0xc213ae]>=_0x194538)
            {
                _0xc213ae.call.value(_0x194538);
                Holders[_0xc213ae]-=_0x194538;
            }
        }
    }

}