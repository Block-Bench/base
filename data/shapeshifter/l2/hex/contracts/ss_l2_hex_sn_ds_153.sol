// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract SingleFuncRegistry {

    address[] _0x4c57ab;

    function _0xe1a9d0() public returns (bool){
        if(_0x4c57ab.length<1500) {
            for(uint i=0;i<350;i++) {
                _0x4c57ab.push(msg.sender);
            }
            return true;

        } else {
            _0x4c57ab = new address[](0);
            return false;
        }
    }
}