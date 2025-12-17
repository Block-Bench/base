// SPDX-License-Identifier: MIT
pragma solidity 0.4.24;

contract Refunder {

address[] private _0x5629c5;
mapping (address => uint) public _0x69352f;

    constructor() {
        _0x5629c5.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        _0x5629c5.push(0x79B483371E87d664cd39491b5F06250165e4b185);
    }

    // bad
    function _0xe76246() public {
        for(uint x; x < _0x5629c5.length; x++) { // arbitrary length iteration based on how many addresses participated
            require(_0x5629c5[x].send(_0x69352f[_0x5629c5[x]])); // doubly bad, now a single failure on send will hold up all funds
        }
    }

}