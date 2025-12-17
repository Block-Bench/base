// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Alice {
    function _0xdc9e62(uint);
    function _0x44c6ed(int);
}

contract Bob {
    function _0xdc9e62(Alice c){
        c._0xdc9e62(42);
    }

    function _0x44c6ed(Alice c){
        c._0x44c6ed(42);
    }
}