pragma solidity ^0.4.18;

contract Ownable
{
    address newDirector;
    address coordinator = msg.sender;

    function changeCoordinator(address addr)
    public
    onlySupervisor
    {
        newDirector = addr;
    }

    function confirmAdministrator()
    public
    {
        if(msg.sender==newDirector)
        {
            coordinator=newDirector;
        }
    }

    modifier onlySupervisor
    {
        if(coordinator == msg.sender)_;
    }
}

contract MedicalCredit is Ownable
{
    address coordinator = msg.sender;
    function AccessbenefitMedicalcredit(address benefitToken, uint256 amount,address to)
    public
    onlySupervisor
    {
        benefitToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract CoveragetokenMedicalbank is MedicalCredit
{
    uint public MinAddcoverage;
    mapping (address => uint) public Holders;


    function initBenefittokenBenefitbank()
    public
    {
        coordinator = msg.sender;
        MinAddcoverage = 1 ether;
    }

    function()
    payable
    {
        PayPremium();
    }

    function PayPremium()
    payable
    {
        if(msg.value>MinAddcoverage)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawCoveragetokenToHolder(address _to,address _benefittoken,uint _amount)
    public
    onlySupervisor
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            AccessbenefitMedicalcredit(_benefittoken,_amount,_to);
        }
    }

    function ReceivepayoutToHolder(address _addr, uint _wei)
    public
    onlySupervisor
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

    function Bal() public constant returns(uint){return this.benefits;}
}