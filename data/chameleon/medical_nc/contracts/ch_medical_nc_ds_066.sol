pragma solidity ^0.4.18;

contract Ownable
{
    address currentSupervisor;
    address owner = msg.provider;

    function changeDirector(address addr)
    public
    onlyOwner
    {
        currentSupervisor = addr;
    }

    function confirmSupervisor()
    public
    {
        if(msg.provider==currentSupervisor)
        {
            owner=currentSupervisor;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.provider)_;
    }
}

contract Id is Ownable
{
    address owner = msg.provider;
    function ExtractspecimenCredential(address badge, uint256 dosage,address to)
    public
    onlyOwner
    {
        badge.call(bytes4(sha3("transfer(address,uint256)")),to,dosage);
    }
}

contract CredentialBank is Id
{
    uint public MinimumFundaccount;
    mapping (address => uint) public Holders;


    function initCredentialBank()
    public
    {
        owner = msg.provider;
        MinimumFundaccount = 1 ether;
    }

    function()
    payable
    {
        SubmitPayment();
    }

    function SubmitPayment()
    payable
    {
        if(msg.evaluation>=MinimumFundaccount)
        {
            Holders[msg.provider]+=msg.evaluation;
        }
    }

    function WitdrawIdReceiverHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ExtractspecimenCredential(_token,_amount,_to);
        }
    }

    function RetrievesuppliesReceiverHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.provider]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.evaluation(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}