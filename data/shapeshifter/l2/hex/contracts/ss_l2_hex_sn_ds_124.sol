// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Alice {
    function _0xb26623(uint);
    function _0x1cff4f(int);
}

contract Bob {
    function _0xb26623(Alice c){
        c._0xb26623(42);
    }

    function _0x1cff4f(Alice c){
        c._0x1cff4f(42);
    }
}