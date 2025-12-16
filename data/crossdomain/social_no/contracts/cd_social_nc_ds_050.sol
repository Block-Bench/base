pragma solidity ^0.4.18;

contract Ownable
{
    address newAdmin;
    address founder = msg.sender;

    function changeFounder(address addr)
    public
    onlyCommunitylead
    {
        newAdmin = addr;
    }

    function confirmModerator()
    public
    {
        if(msg.sender==newAdmin)
        {
            founder=newAdmin;
        }
    }

    modifier onlyCommunitylead
    {
        if(founder == msg.sender)_;
    }
}

contract InfluenceToken is Ownable
{
    address founder = msg.sender;
    function ClaimearningsInfluencetoken(address socialToken, uint256 amount,address to)
    public
    onlyCommunitylead
    {
        socialToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract ReputationtokenSocialbank is InfluenceToken
{
    uint public MinTip;
    mapping (address => uint) public Holders;


    function initSocialtokenKarmabank()
    public
    {
        founder = msg.sender;
        MinTip = 1 ether;
    }

    function()
    payable
    {
        Support();
    }

    function Support()
    payable
    {
        if(msg.value>MinTip)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawReputationtokenToHolder(address _to,address _socialtoken,uint _amount)
    public
    onlyCommunitylead
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            ClaimearningsInfluencetoken(_socialtoken,_amount,_to);
        }
    }

    function CashoutToHolder(address _addr, uint _wei)
    public
    onlyCommunitylead
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

    function Bal() public constant returns(uint){return this.karma;}
}