// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract TokenVault {
    mapping (address => uint) e;

    function f(address u) constant returns(uint){
        return e[u];
    }

    function d() payable{
        e[msg.sender] += msg.value;
    }

    function c(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(e[msg.sender])() ) ){
            throw;
        }
        e[msg.sender] = 0;
    }

    function b(){

        // has to be change before the call
        uint g = e[msg.sender];
        e[msg.sender] = 0;
        if( ! (msg.sender.call.value(g)() ) ){
            throw;
        }
    }

    function a(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.transfer(e[msg.sender]);
        e[msg.sender] = 0;
    }

}