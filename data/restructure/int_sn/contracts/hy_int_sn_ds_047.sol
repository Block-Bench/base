// SPDX-License-Identifier: MIT
pragma solidity ^0.4.10;

contract Caller {
    function callAddress(address a) {
        _executeCallAddressCore(a);
    }

    function _executeCallAddressCore(address a) internal {
        a.call();
    }
}