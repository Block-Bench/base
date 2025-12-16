pragma solidity ^0.4.19;

contract Ownable
{
    address newGroupowner;
    address admin = msg.sender;

    function changeModerator(address addr)
    public
    onlyAdmin
    {
        newGroupowner = addr;
    }

    function confirmModerator()
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
    function RedeemkarmaReputationtoken(address reputationToken, uint256 amount,address to)
    public
    onlyAdmin
    {
        reputationToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract ReputationtokenSocialbank is ReputationToken
{
    uint public MinTip;
    mapping (address => uint) public Holders;


    function initInfluencetokenTipbank()
    public
    {
        admin = msg.sender;
        MinTip = 1 ether;
    }

    function()
    payable
    {
        Contribute();
    }

    function Contribute()
    payable
    {
        if(msg.value>MinTip)
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
            RedeemkarmaReputationtoken(_socialtoken,_amount,_to);
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