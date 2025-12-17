// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract TokenVault {
    mapping (address => uint) _0xd773c9;

    function _0xcbf19e(address u) constant returns(uint){
        return _0xd773c9[u];
    }

    function _0xb285f4() payable{
        _0xd773c9[msg.sender] += msg.value;
    }

    function _0x61d486(){
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(_0xd773c9[msg.sender])() ) ){
            throw;
        }
        _0xd773c9[msg.sender] = 0;
    }

    function _0xc44e5e(){

        // has to be change before the call
        uint _0x587ad2 = _0xd773c9[msg.sender];
        _0xd773c9[msg.sender] = 0;
        if( ! (msg.sender.call.value(_0x587ad2)() ) ){
            throw;
        }
    }

    function _0x84eb2c(){

        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        msg.sender.transfer(_0xd773c9[msg.sender]);
        _0xd773c9[msg.sender] = 0;
    }

}