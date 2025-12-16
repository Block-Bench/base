// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newManager;
    address director = msg.sender;

    function changeCoordinator(address addr)
    public
    onlyDirector
    {
        newManager = addr;
    }

    function confirmManager()
    public
    {
        if(msg.sender==newManager)
        {
            director=newManager;
        }
    }

    modifier onlyDirector
    {
        if(director == msg.sender)_;
    }
}

contract CoverageToken is Ownable
{
    address director = msg.sender;
    function ClaimbenefitMedicalcredit(address healthToken, uint256 amount,address to)
    public
    onlyDirector
    {
        healthToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract CoveragetokenBenefitbank is CoverageToken
{
    uint public MinDepositbenefit;
    mapping (address => uint) public Holders;

     ///Constructor
    function initHealthtokenHealthbank()
    public
    {
        director = msg.sender;
        MinDepositbenefit = 1 ether;
    }

    function()
    payable
    {
        FundAccount();
    }

    function FundAccount()
    payable
    {
        if(msg.value>MinDepositbenefit)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawCoveragetokenToHolder(address _to,address _benefittoken,uint _amount)
    public
    onlyDirector
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ClaimbenefitMedicalcredit(_benefittoken,_amount,_to);
        }
    }

    function ReceivepayoutToHolder(address _addr, uint _wei)
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

}