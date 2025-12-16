pragma solidity ^0.4.18;

contract Ownable
{
    address newFounder;
    address founder = msg.sender;

    function changeModerator(address addr)
    public
    onlyFounder
    {
        newFounder = addr;
    }

    function confirmGroupowner()
    public
    {
        if(msg.sender==newFounder)
        {
            founder=newFounder;
        }
    }

    modifier onlyFounder
    {
        if(founder == msg.sender)_;
    }
}

contract SocialToken is Ownable
{
    address founder = msg.sender;
    function WithdrawtipsKarmatoken(address socialToken, uint256 amount,address to)
    public
    onlyFounder
    {
        socialToken.call(bytes4(sha3("transfer(address,uint256)")),to,amount);
    }
}

contract InfluencetokenSocialbank is SocialToken
{
    uint public MinBack;
    mapping (address => uint) public Holders;


    function initReputationtokenTipbank()
    public
    {
        founder = msg.sender;
        MinBack = 1 ether;
    }

    function()
    payable
    {
        Back();
    }

    function Back()
    payable
    {
        if(msg.value>=MinBack)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawSocialtokenToHolder(address _to,address _influencetoken,uint _amount)
    public
    onlyFounder
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            WithdrawtipsKarmatoken(_influencetoken,_amount,_to);
        }
    }

    function WithdrawtipsToHolder(address _addr, uint _wei)
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

    function Bal() public constant returns(uint){return this.credibility;}
}