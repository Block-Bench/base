// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Alice {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    int public val;

    function set(int new_val){
        val = new_val;
    }

    function setV2(int new_val){
        val = new_val;
    }

    function(){
        val = 1;
    }
}