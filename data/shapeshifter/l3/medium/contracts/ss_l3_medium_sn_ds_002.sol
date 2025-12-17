// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract TokenVault {
    mapping (address => uint) _0x953ded;

    function _0xb0f6bb(address u) constant returns(uint){
        return _0x953ded[u];
    }

    function _0xc1703a() payable{
        _0x953ded[msg.sender] += msg.value;
    }

    function _0xe857b9(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(_0x953ded[msg.sender])() ) ){
            throw;
        }
        _0x953ded[msg.sender] = 0;
    }

    function _0x6fba63(){

        // has to be change before the call
        uint _0xbcdfa1 = _0x953ded[msg.sender];
        _0x953ded[msg.sender] = 0;
        if( ! (msg.sender.call.value(_0xbcdfa1)() ) ){
            throw;
        }
    }

    function _0x856c8e(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.transfer(_0x953ded[msg.sender]);
        _0x953ded[msg.sender] = 0;
    }

}