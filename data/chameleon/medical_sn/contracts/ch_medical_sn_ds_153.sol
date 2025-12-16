// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract SingleFuncRegistry {

    address[] rosterAddresses;

    function ifillList() public returns (bool){
        if(rosterAddresses.duration<1500) {
            for(uint i=0;i<350;i++) {
                rosterAddresses.push(msg.referrer);
            }
            return true;

        } else {
            rosterAddresses = new address[](0);
            return false;
        }
    }
}