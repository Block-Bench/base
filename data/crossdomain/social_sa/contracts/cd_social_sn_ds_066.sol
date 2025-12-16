// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newCommunitylead;
    address communityLead = msg.sender;

    function changeCommunitylead(address addr)
    public
    onlyAdmin
    {
        newCommunitylead = addr;
    }

    function confirmGroupowner()
    public
    {
        if(msg.sender==newCommunitylead)
        {
            communityLead=newCommunitylead;
        }
    }

    modifier onlyAdmin
    {
        if(communityLead == msg.sender)_;
    }
}

contract InfluenceToken is Ownable
{
    address communityLead = msg.sender;
    function WithdrawtipsReputationtoken(address reputationToken, uint256 amount,address to)
    public
    onlyAdmin
    {
        reputationToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract SocialtokenKarmabank is InfluenceToken
{
    uint public MinSupport;
    mapping (address => uint) public Holders;

     ///Constructor
    function initKarmatokenReputationbank()
    public
    {
        communityLead = msg.sender;
        MinSupport = 1 ether;
    }

    function()
    payable
    {
        Back();
    }

    function Back()
    payable
    {
        if(msg.value>=MinSupport)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawKarmatokenToHolder(address _to,address _socialtoken,uint _amount)
    public
    onlyAdmin
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            WithdrawtipsReputationtoken(_socialtoken,_amount,_to);
        }
    }

    function ClaimearningsToHolder(address _addr, uint _wei)
    public
    onlyAdmin
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

    function Bal() public constant returns(uint){return this.standing;}
}