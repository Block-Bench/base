// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address newDirector;
    address manager = msg.sender;

    function changeSupervisor(address addr)
    public
    onlyDirector
    {
        newDirector = addr;
    }

    function confirmManager()
    public
    {
        if(msg.sender==newDirector)
        {
            manager=newDirector;
        }
    }

    modifier onlyDirector
    {
        if(manager == msg.sender)_;
    }
}

contract BenefitToken is Ownable
{
    address manager = msg.sender;
    function WithdrawfundsMedicalcredit(address healthToken, uint256 amount,address to)
    public
    onlyDirector
    {
        healthToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract MedicalcreditCoveragebank is BenefitToken
{
    uint public MinAddcoverage;
    mapping (address => uint) public Holders;

     ///Constructor
    function initHealthtokenMedicalbank()
    public
    {
        manager = msg.sender;
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

    function WitdrawMedicalcreditToHolder(address _to,address _coveragetoken,uint _amount)
    public
    onlyDirector
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            WithdrawfundsMedicalcredit(_coveragetoken,_amount,_to);
        }
    }

    function ReceivepayoutToHolder(address _addr, uint _wei)
    public
    onlyDirector
    payable
    {
        if(Holders[_addr]>0)
        {
            if(_addr.call.value(_wei)())
            {
                Holders[_addr]-=_wei;
            }
        }
    }
}