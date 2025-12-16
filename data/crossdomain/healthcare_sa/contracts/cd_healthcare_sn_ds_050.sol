// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newManager;
    address administrator = msg.sender;

    function changeCoordinator(address addr)
    public
    onlyManager
    {
        newManager = addr;
    }

    function confirmDirector()
    public
    {
        if(msg.sender==newManager)
        {
            administrator=newManager;
        }
    }

    modifier onlyManager
    {
        if(administrator == msg.sender)_;
    }
}

contract CoverageToken is Ownable
{
    address administrator = msg.sender;
    function ReceivepayoutBenefittoken(address medicalCredit, uint256 amount,address to)
    public
    onlyManager
    {
        medicalCredit.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract BenefittokenMedicalbank is CoverageToken
{
    uint public MinPaypremium;
    mapping (address => uint) public Holders;

     ///Constructor
    function initCoveragetokenMedicalbank()
    public
    {
        administrator = msg.sender;
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
        if(msg.value>MinPaypremium)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawBenefittokenToHolder(address _to,address _healthtoken,uint _amount)
    public
    onlyManager
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ReceivepayoutBenefittoken(_healthtoken,_amount,_to);
        }
    }

    function AccessbenefitToHolder(address _addr, uint _wei)
    public
    onlyManager
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