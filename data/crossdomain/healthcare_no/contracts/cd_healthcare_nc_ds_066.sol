pragma solidity ^0.4.18;

contract Ownable
{
    address newCoordinator;
    address coordinator = msg.sender;

    function changeAdministrator(address addr)
    public
    onlyCoordinator
    {
        newCoordinator = addr;
    }

    function confirmManager()
    public
    {
        if(msg.sender==newCoordinator)
        {
            coordinator=newCoordinator;
        }
    }

    modifier onlyCoordinator
    {
        if(coordinator == msg.sender)_;
    }
}

contract BenefitToken is Ownable
{
    address coordinator = msg.sender;
    function WithdrawfundsHealthtoken(address benefitToken, uint256 amount,address to)
    public
    onlyCoordinator
    {
        benefitToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract MedicalcreditMedicalbank is BenefitToken
{
    uint public MinFundaccount;
    mapping (address => uint) public Holders;


    function initHealthtokenCoveragebank()
    public
    {
        coordinator = msg.sender;
        MinFundaccount = 1 ether;
    }

    function()
    payable
    {
        PayPremium();
    }

    function PayPremium()
    payable
    {
        if(msg.value>=MinFundaccount)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawMedicalcreditToHolder(address _to,address _healthtoken,uint _amount)
    public
    onlyCoordinator
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            WithdrawfundsHealthtoken(_healthtoken,_amount,_to);
        }
    }

    function AccessbenefitToHolder(address _addr, uint _wei)
    public
    onlyCoordinator
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

    function Bal() public constant returns(uint){return this.coverage;}
}