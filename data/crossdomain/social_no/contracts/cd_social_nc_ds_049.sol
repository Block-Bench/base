pragma solidity ^0.4.18;

contract Ownable
{
    address newCommunitylead;
    address moderator = msg.sender;

    function changeModerator(address addr)
    public
    onlyFounder
    {
        newCommunitylead = addr;
    }

    function confirmFounder()
    public
    {
        if(msg.sender==newCommunitylead)
        {
            moderator=newCommunitylead;
        }
    }

    modifier onlyFounder
    {
        if(moderator == msg.sender)_;
    }
}

contract ReputationToken is Ownable
{
    address moderator = msg.sender;
    function CashoutReputationtoken(address influenceToken, uint256 amount,address to)
    public
    onlyFounder
    {
        influenceToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract InfluencetokenKarmabank is ReputationToken
{
    uint public MinDonate;
    mapping (address => uint) public Holders;


    function initInfluencetokenReputationbank()
    public
    {
        moderator = msg.sender;
        MinDonate = 1 ether;
    }

    function()
    payable
    {
        Back();
    }

    function Back()
    payable
    {
        if(msg.value>MinDonate)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawReputationtokenToHolder(address _to,address _reputationtoken,uint _amount)
    public
    onlyFounder
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            CashoutReputationtoken(_reputationtoken,_amount,_to);
        }
    }

    function CashoutToHolder(address _addr, uint _wei)
    public
    onlyFounder
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