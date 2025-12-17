// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract TokenVault {
    mapping (address => uint) _0x4d652a;

    function _0x938285(address u) constant returns(uint){
        return _0x4d652a[u];
    }

    function _0xf09d5a() payable{
        _0x4d652a[msg.sender] += msg.value;
    }

    function _0x039889(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(_0x4d652a[msg.sender])() ) ){
            throw;
        }
        _0x4d652a[msg.sender] = 0;
    }

    function _0x297db2(){

        // has to be change before the call
        uint _0xdefde6 = _0x4d652a[msg.sender];
        _0x4d652a[msg.sender] = 0;
        if( ! (msg.sender.call.value(_0xdefde6)() ) ){
            throw;
        }
    }

    function _0xe713d6(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.transfer(_0x4d652a[msg.sender]);
        _0x4d652a[msg.sender] = 0;
    }

}