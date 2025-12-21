// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Ledger {
    uint private _0x0af26b=0;

    function _0x37ecc3(uint value) returns (bool){
        _0x0af26b += value;

        // possible auditor assert
        // assert(sellerBalance >= value);
    }

    function _0xd9638f(uint value) returns (bool){
        require(value + _0x0af26b >= _0x0af26b);
        _0x0af26b += value;
    }
}