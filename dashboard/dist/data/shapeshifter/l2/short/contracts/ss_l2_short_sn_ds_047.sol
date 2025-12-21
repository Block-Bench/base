// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract Caller {
    function a(address a) {
        a.call();
    }
}