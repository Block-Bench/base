// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Alice {
    function set(uint);
    function setV2(int);
}

contract Bob {
    function set(Alice c){
        c.set(42);
    }

    function setV2(Alice c){
        c.setV2(42);
    }
}