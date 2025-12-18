// SPDX-License-Identifier: MIT
pragma solidity 0.4.24;

contract Refunder {

address[] private _0x185439;
mapping (address => uint) public _0x383e9b;

    constructor() {
        _0x185439.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        _0x185439.push(0x79B483371E87d664cd39491b5F06250165e4b185);
    }

    // bad
    function _0x088fb5() public {
        for(uint x; x < _0x185439.length; x++) { // arbitrary length iteration based on how many addresses participated
            require(_0x185439[x].send(_0x383e9b[_0x185439[x]])); // doubly bad, now a single failure on send will hold up all funds
        }
    }

}