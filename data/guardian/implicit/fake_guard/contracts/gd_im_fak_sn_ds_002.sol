// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract TokenVault {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    mapping (address => uint) userBalance;

    function getBalance(address u) constant returns(uint){
        return userBalance[u];
    }

    function addToBalance() payable{
        userBalance[msg.sender] += msg.value;
    }

    function withdrawBalance(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(userBalance[msg.sender])() ) ){
            throw;
        }
        userBalance[msg.sender] = 0;
    }

    function withdrawBalanceV2(){

        // has to be change before the call
        uint amount = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){
            throw;
        }
    }

    function withdrawBalanceV3(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender/* Protected by reentrancy guard */ .transfer(userBalance[msg.sender]);
        userBalance[msg.sender] = 0;
    }

}