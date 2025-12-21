// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {

    address _0xc7cd5b;

    function MyContract() public {
        _0xc7cd5b = msg.sender;
    }

    function _0x27e14f(address _0xf759a0, uint _0xb34f98) public {
        require(tx.origin == _0xc7cd5b);
        _0xf759a0.transfer(_0xb34f98);
    }

}