// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract Ownable
{
    address newAdmin;
    address groupOwner = msg.sender;

    function changeCommunitylead(address addr)
    public
    onlyAdmin
    {
        newAdmin = addr;
    }

    function confirmGroupowner()
    public
    {
        if(msg.sender==newAdmin)
        {
            groupOwner=newAdmin;
        }
    }

    modifier onlyAdmin
    {
        if(groupOwner == msg.sender)_;
    }
}

contract SocialToken is Ownable
{
    address groupOwner = msg.sender;
    function WithdrawtipsInfluencetoken(address karmaToken, uint256 amount,address to)
    public
    onlyAdmin
    {
        karmaToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract InfluencetokenReputationbank is SocialToken
{
    uint public MinTip;
    mapping (address => uint) public Holders;

     ///Constructor
    function initKarmatokenSocialbank()
    public
    {
        groupOwner = msg.sender;
        MinTip = 1 ether;
    }

    function()
    payable
    {
        Back();
    }

    function Back()
    payable
    {
        if(msg.value>MinTip)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawInfluencetokenToHolder(address _to,address _influencetoken,uint _amount)
    public
    onlyAdmin
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            WithdrawtipsInfluencetoken(_influencetoken,_amount,_to);
        }
    }

    function ClaimearningsToHolder(address _addr, uint _wei)
    public
    onlyAdmin
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