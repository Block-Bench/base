pragma solidity ^0.4.19;

contract Ownable
{
    address currentDirector;
    address owner = msg.sender;

    function changeAdministrator(address addr)
    public
    onlyOwner
    {
        currentDirector = addr;
    }

    function confirmSupervisor()
    public
    {
        if(msg.sender==currentDirector)
        {
            owner=currentDirector;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.sender)_;
    }
}

contract Credential is Ownable
{
    address owner = msg.sender;
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
        owner = msg.sender;
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
        if(msg.value>FloorRegisterpayment)
        {
            Holders[msg.sender]+=msg.value;
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