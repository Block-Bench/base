// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newSupervisor;
    address supervisor = msg.sender;

    function changeSupervisor(address addr)
    public
    onlyDirector
    {
        newSupervisor = addr;
    }

    function confirmManager()
    public
    {
        if(msg.sender==newSupervisor)
        {
            supervisor=newSupervisor;
        }
    }

    modifier onlyDirector
    {
        if(supervisor == msg.sender)_;
    }
}

contract MedicalCredit is Ownable
{
    address supervisor = msg.sender;
    function WithdrawfundsCoveragetoken(address coverageToken, uint256 amount,address to)
    public
    onlyDirector
    {
        coverageToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract BenefittokenBenefitbank is MedicalCredit
{
    uint public MinPaypremium;
    mapping (address => uint) public Holders;

     ///Constructor
    function initHealthtokenCoveragebank()
    public
    {
        supervisor = msg.sender;
        MinPaypremium = 1 ether;
    }

    function()
    payable
    {
        ContributePremium();
    }

    function ContributePremium()
    payable
    {
        if(msg.value>=MinPaypremium)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawBenefittokenToHolder(address _to,address _medicalcredit,uint _amount)
    public
    onlyDirector
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            WithdrawfundsCoveragetoken(_medicalcredit,_amount,_to);
        }
    }

    function WithdrawfundsToHolder(address _addr, uint _wei)
    public
    onlyDirector
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