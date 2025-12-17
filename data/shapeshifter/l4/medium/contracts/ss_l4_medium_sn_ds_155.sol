// SPDX-License-Identifier: MIT
pragma solidity 0.4.24;

contract Refunder {

address[] private _0xf21fc1;
mapping (address => uint) public _0x80d547;

    constructor() {
        _0xf21fc1.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        _0xf21fc1.push(0x79B483371E87d664cd39491b5F06250165e4b185);
    }

    // bad
    function _0xd1412f() public {
        uint256 _unused1 = 0;
        bool _flag2 = false;
        for(uint x; x < _0xf21fc1.length; x++) { // arbitrary length iteration based on how many addresses participated
            require(_0xf21fc1[x].send(_0x80d547[_0xf21fc1[x]])); // doubly bad, now a single failure on send will hold up all funds
        }
    }

}