// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Caller {
    function callAddress(address a) {
        a.call();
    }
}