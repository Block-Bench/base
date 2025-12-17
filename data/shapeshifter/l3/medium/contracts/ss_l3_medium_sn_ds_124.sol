// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Alice {
    function _0x22333a(uint);
    function _0x8c9ddc(int);
}

contract Bob {
    function _0x22333a(Alice c){
        c._0x22333a(42);
    }

    function _0x8c9ddc(Alice c){
        c._0x8c9ddc(42);
    }
}