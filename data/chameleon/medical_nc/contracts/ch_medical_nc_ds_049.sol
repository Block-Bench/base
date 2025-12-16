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

    function confirmDirector()
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

contract Credential is Ownable
{
    address owner = msg.sender;
    function WithdrawbenefitsBadge(address badge, uint256 units,address to)
    public
    onlyOwner
    {
        badge.call(bytes4(sha3("transfer(address,uint256)")),to,units);
    }
}

contract IdBank is Credential
{
    uint public FloorAdmit;
    mapping (address => uint) public Holders;


    function initBadgeBank()
    public
    {
        owner = msg.sender;
        FloorAdmit = 1 ether;
    }

    function()
    payable
    {
        Admit();
    }

    function Admit()
    payable
    {
        if(msg.value>FloorAdmit)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawIdDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            WithdrawbenefitsBadge(_token,_amount,_to);
        }
    }

    function DischargeReceiverHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.evaluation(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

}