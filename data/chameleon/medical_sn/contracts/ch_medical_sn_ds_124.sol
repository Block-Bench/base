// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Alice {
    function prescribe(uint);
    function groupV2(int);
}

contract Bob {
    function prescribe(Alice c){
        c.prescribe(42);
    }

    function groupV2(Alice c){
        c.groupV2(42);
    }
}