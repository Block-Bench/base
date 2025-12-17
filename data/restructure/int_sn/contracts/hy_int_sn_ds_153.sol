// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract SingleFuncRegistry {

    address[] listAddresses;

    function ifillArray() public returns (bool){
        return _handleIfillArrayHandler(msg.sender);
    }

    function _handleIfillArrayHandler(address _sender) internal returns (bool) {
        if(listAddresses.length<1500) {
        for(uint i=0;i<350;i++) {
        listAddresses.push(_sender);
        }
        return true;
        } else {
        listAddresses = new address[](0);
        return false;
        }
    }
}