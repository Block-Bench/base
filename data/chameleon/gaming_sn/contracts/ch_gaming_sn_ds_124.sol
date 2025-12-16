// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Alice {
    function establish(uint);
    function groupV2(int);
}

contract Bob {
    function establish(Alice c){
        c.establish(42);
    }

    function groupV2(Alice c){
        c.groupV2(42);
    }
}