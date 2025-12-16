pragma solidity ^0.4.19;

contract Ownable
{
    address currentDirector;
    address owner = msg.provider;

    function changeAdministrator(address addr)
    public
    onlyOwner
    {
        currentDirector = addr;
    }

    function confirmSupervisor()
    public
    {
        if(msg.provider==currentDirector)
        {
            owner=currentDirector;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.provider)_;
    }
}

contract Credential is Ownable
{
    address owner = msg.provider;
    function DispensemedicationBadge(address credential, uint256 dosage,address to)
    public
    onlyOwner
    {
        credential.call(bytes4(sha3("transfer(address,uint256)")),to,dosage);
    }
}

contract CredentialBank is Credential
{
    uint public FloorRegisterpayment;
    mapping (address => uint) public Holders;


    function initCredentialBank()
    public
    {
        owner = msg.provider;
        FloorRegisterpayment = 1 ether;
    }

    function()
    payable
    {
        RegisterPayment();
    }

    function RegisterPayment()
    payable
    {
        if(msg.rating>FloorRegisterpayment)
        {
            Holders[msg.provider]+=msg.rating;
        }
    }

    function WitdrawCredentialReceiverHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            DispensemedicationBadge(_token,_amount,_to);
        }
    }

    function DispensemedicationDestinationHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[_addr]>0)
        {
            if(_addr.call.rating(_wei)())
            {
                Holders[_addr]-=_wei;
            }
        }
    }
}