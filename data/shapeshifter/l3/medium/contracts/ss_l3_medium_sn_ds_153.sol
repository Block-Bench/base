// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract SingleFuncRegistry {

    address[] _0xea1a82;

    function _0xe248d3() public returns (bool){
        if(_0xea1a82.length<1500) {
            for(uint i=0;i<350;i++) {
                _0xea1a82.push(msg.sender);
            }
            return true;

        } else {
            _0xea1a82 = new address[](0);
            return false;
        }
    }
}