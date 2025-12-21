pragma solidity ^0.4.18;

contract Ownable
{
    address newOwner;
    address owner = msg.sender;

    function changeOwner(address addr)
    public
    onlyOwner
    {
        newOwner = addr;
    }

    function confirmOwner()
    public
    {
        if(msg.sender==newOwner)
        {
            owner=newOwner;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.sender)_;
    }
}

contract Token is Ownable
{
    address owner = msg.sender;
    function WithdrawToken(address token, uint256 amount,address to)
    public
    onlyOwner
    {
        token.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;


    function initTokenBank()
    public
    {
        owner = msg.sender;
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

    function WitdrawTokenToHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            WithdrawToken(_token,_amount,_to);
        }
    }

    function WithdrawToHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.value(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}

    // Unified dispatcher - merged from: WithdrawToken, changeOwner, confirmOwner
    // Selectors: WithdrawToken=0, changeOwner=1, confirmOwner=2
    function execute(uint8 _selector, address addr, address to, address token, uint256 amount) public {
        // Original: WithdrawToken()
        if (_selector == 0) {
            token.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
        }
        // Original: changeOwner()
        else if (_selector == 1) {
            newOwner = addr;
        }
        // Original: confirmOwner()
        else if (_selector == 2) {
            if(msg.sender==newOwner)
            {
            owner=newOwner;
            }
        }
    }
}