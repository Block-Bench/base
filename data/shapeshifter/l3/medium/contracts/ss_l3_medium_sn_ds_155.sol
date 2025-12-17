// SPDX-License-Identifier: MIT
pragma solidity 0.4.24;

contract Refunder {

address[] private _0xb9592c;
mapping (address => uint) public _0x5b4445;

    constructor() {
        _0xb9592c.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        _0xb9592c.push(0x79B483371E87d664cd39491b5F06250165e4b185);
    }

    // bad
    function _0xc12e8d() public {
        for(uint x; x < _0xb9592c.length; x++) { // arbitrary length iteration based on how many addresses participated
            require(_0xb9592c[x].send(_0x5b4445[_0xb9592c[x]])); // doubly bad, now a single failure on send will hold up all funds
        }
    }

}