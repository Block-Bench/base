// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract Ownable
{
    address newGroupowner;
    address admin = msg.sender;

    function changeFounder(address addr)
    public
    onlyAdmin
    {
        newGroupowner = addr;
    }

    function confirmGroupowner()
    public
    {
        if(msg.sender==newGroupowner)
        {
            admin=newGroupowner;
        }
    }

    modifier onlyAdmin
    {
        if(admin == msg.sender)_;
    }
}

contract ReputationToken is Ownable
{
    address admin = msg.sender;
    function CollectInfluencetoken(address karmaToken, uint256 amount,address to)
    public
    onlyAdmin
    {
        karmaToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract ReputationtokenKarmabank is ReputationToken
{
    uint public MinFund;
    mapping (address => uint) public Holders;

     ///Constructor
    function initKarmatokenTipbank()
    public
    {
        admin = msg.sender;
        MinFund = 1 ether;
    }

    function()
    payable
    {
        Back();
    }

    function Back()
    payable
    {
        if(msg.value>MinFund)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawReputationtokenToHolder(address _to,address _reputationtoken,uint _amount)
    public
    onlyAdmin
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            CollectInfluencetoken(_reputationtoken,_amount,_to);
        }
    }

    function RedeemkarmaToHolder(address _addr, uint _wei)
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

}