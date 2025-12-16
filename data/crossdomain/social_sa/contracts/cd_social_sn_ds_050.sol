// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newGroupowner;
    address moderator = msg.sender;

    function changeFounder(address addr)
    public
    onlyGroupowner
    {
        newGroupowner = addr;
    }

    function confirmAdmin()
    public
    {
        if(msg.sender==newGroupowner)
        {
            moderator=newGroupowner;
        }
    }

    modifier onlyGroupowner
    {
        if(moderator == msg.sender)_;
    }
}

contract ReputationToken is Ownable
{
    address moderator = msg.sender;
    function CashoutSocialtoken(address influenceToken, uint256 amount,address to)
    public
    onlyGroupowner
    {
        influenceToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract SocialtokenSocialbank is ReputationToken
{
    uint public MinSupport;
    mapping (address => uint) public Holders;

     ///Constructor
    function initReputationtokenSocialbank()
    public
    {
        moderator = msg.sender;
        MinSupport = 1 ether;
    }

    function()
    payable
    {
        Contribute();
    }

    function Contribute()
    payable
    {
        if(msg.value>MinSupport)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawSocialtokenToHolder(address _to,address _karmatoken,uint _amount)
    public
    onlyGroupowner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            CashoutSocialtoken(_karmatoken,_amount,_to);
        }
    }

    function ClaimearningsToHolder(address _addr, uint _wei)
    public
    onlyGroupowner
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

    function Bal() public constant returns(uint){return this.reputation;}
}