// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Alice {
    function _0x10263b(uint);
    function _0xe4b5e4(int);
}

contract Bob {
    function _0x10263b(Alice c){
        c._0x10263b(42);
    }

    function _0xe4b5e4(Alice c){
        c._0xe4b5e4(42);
    }
}