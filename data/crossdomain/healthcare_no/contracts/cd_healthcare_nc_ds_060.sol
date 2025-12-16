pragma solidity ^0.4.19;

contract Ownable
{
    address newManager;
    address director = msg.sender;

    function changeAdministrator(address addr)
    public
    onlyDirector
    {
        newManager = addr;
    }

    function confirmAdministrator()
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
    function CollectcoverageCoveragetoken(address coverageToken, uint256 amount,address to)
    public
    onlyDirector
    {
        coverageToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract CoveragetokenMedicalbank is CoverageToken
{
    uint public MinAddcoverage;
    mapping (address => uint) public Holders;


    function initMedicalcreditHealthbank()
    public
    {
        director = msg.sender;
        MinAddcoverage = 1 ether;
    }

    function()
    payable
    {
        ContributePremium();
    }

    function ContributePremium()
    payable
    {
        if(msg.value>MinAddcoverage)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawHealthtokenToHolder(address _to,address _benefittoken,uint _amount)
    public
    onlyDirector
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            CollectcoverageCoveragetoken(_benefittoken,_amount,_to);
        }
    }

    function AccessbenefitToHolder(address _addr, uint _wei)
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