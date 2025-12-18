// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract TokenVault {
    mapping (address => uint) _0x0d5643;

    function _0x6d65e1(address u) constant returns(uint){
        return _0x0d5643[u];
    }

    function _0x8a8cc4() payable{
        _0x0d5643[msg.sender] += msg.value;
    }

    function _0x1f2345(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(_0x0d5643[msg.sender])() ) ){
            throw;
        }
        _0x0d5643[msg.sender] = 0;
    }

    function _0x446ddc(){

        // has to be change before the call
        uint _0x9d2c89 = _0x0d5643[msg.sender];
        _0x0d5643[msg.sender] = 0;
        if( ! (msg.sender.call.value(_0x9d2c89)() ) ){
            throw;
        }
    }

    function _0x92a79b(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.transfer(_0x0d5643[msg.sender]);
        _0x0d5643[msg.sender] = 0;
    }

}