// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract SingleFuncRegistry {

    address[] _0x78883e;

    function _0xc12c46() public returns (bool){
        bool _flag1 = false;
        bool _flag2 = false;
        if(_0x78883e.length<1500) {
            for(uint i=0;i<350;i++) {
                _0x78883e.push(msg.sender);
            }
            return true;

        } else {
            _0x78883e = new address[](0);
            return false;
        }
    }
}