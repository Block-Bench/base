// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract Invoker {
    function summonheroLocation(address a) {
        a.call();
    }
}