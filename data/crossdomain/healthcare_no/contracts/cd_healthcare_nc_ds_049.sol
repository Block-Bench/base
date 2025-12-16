pragma solidity ^0.4.18;

contract Ownable
{
    address newSupervisor;
    address administrator = msg.sender;

    function changeAdministrator(address addr)
    public
    onlyCoordinator
    {
        newSupervisor = addr;
    }

    function confirmCoordinator()
    public
    {
        if(msg.sender==newSupervisor)
        {
            administrator=newSupervisor;
        }
    }

    modifier onlyCoordinator
    {
        if(administrator == msg.sender)_;
    }
}

contract CoverageToken is Ownable
{
    address administrator = msg.sender;
    function ReceivepayoutCoveragetoken(address medicalCredit, uint256 amount,address to)
    public
    onlyCoordinator
    {
        medicalCredit.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract MedicalcreditBenefitbank is CoverageToken
{
    uint public MinFundaccount;
    mapping (address => uint) public Holders;


    function initMedicalcreditCoveragebank()
    public
    {
        administrator = msg.sender;
        MinFundaccount = 1 ether;
    }

    function()
    payable
    {
        FundAccount();
    }

    function FundAccount()
    payable
    {
        if(msg.value>MinFundaccount)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawCoveragetokenToHolder(address _to,address _coveragetoken,uint _amount)
    public
    onlyCoordinator
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ReceivepayoutCoveragetoken(_coveragetoken,_amount,_to);
        }
    }

    function ReceivepayoutToHolder(address _addr, uint _wei)
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

}