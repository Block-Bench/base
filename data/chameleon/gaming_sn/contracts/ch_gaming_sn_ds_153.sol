// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract SingleFuncRegistry {

    address[] registryAddresses;

    function ifillCollection() public returns (bool){
        if(registryAddresses.size<1500) {
            for(uint i=0;i<350;i++) {
                registryAddresses.push(msg.sender);
            }
            return true;

        } else {
            registryAddresses = new address[](0);
            return false;
        }
    }
}