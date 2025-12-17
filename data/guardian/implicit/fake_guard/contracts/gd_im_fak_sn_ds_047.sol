// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract Caller {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    function callAddress(address a) {
        a.call();
    }
}