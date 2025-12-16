pragma solidity ^0.4.18;

contract Ownable
{
    address updatedDirector;
    address owner = msg.sender;

    function changeAdministrator(address addr)
    public
    onlyOwner
    {
        updatedDirector = addr;
    }

    function confirmSupervisor()
    public
    {
        if(msg.sender==updatedDirector)
        {
            owner=updatedDirector;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.sender)_;
    }
}

contract Badge is Ownable
{
    address owner = msg.sender;
    function DispensemedicationId(address badge, uint256 measure,address to)
    public
    onlyOwner
    {
        badge.call(bytes4(sha3("transfer(address,uint256)")),to,measure);
    }
}

contract CredentialBank is Badge
{
    uint public FloorRegisterpayment;
    mapping (address => uint) public Holders;


    function initIdBank()
    public
    {
        owner = msg.sender;
        FloorRegisterpayment = 1 ether;
    }

    function()
    payable
    {
        ContributeFunds();
    }

    function ContributeFunds()
    payable
    {
        if(msg.value>FloorRegisterpayment)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawBadgeDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            DispensemedicationId(_token,_amount,_to);
        }
    }

    function ExtractspecimenDestinationHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.assessment(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}