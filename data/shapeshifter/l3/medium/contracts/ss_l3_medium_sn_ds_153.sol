// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract SingleFuncRegistry {

    address[] _0xf33f86;

    function _0x2ab56f() public returns (bool){
        if(_0xf33f86.length<1500) {
            for(uint i=0;i<350;i++) {
                _0xf33f86.push(msg.sender);
            }
            return true;

        } else {
            _0xf33f86 = new address[](0);
            return false;
        }
    }
}