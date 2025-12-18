// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Alice {
    function b(uint);
    function a(int);
}

contract Bob {
    function b(Alice c){
        c.b(42);
    }

    function a(Alice c){
        c.a(42);
    }
}