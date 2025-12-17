// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public _0x315c2f;
    bool public _0xb5d6ff;
    uint public _0x67cc31;

    function EthTxOrderDependenceMinimal() public {
        _0x315c2f = msg.sender;
    }

    function _0x940a59() public payable {
        require (!_0xb5d6ff);

        require(msg.sender == _0x315c2f);
        _0x315c2f.transfer(_0x67cc31);
        _0x67cc31 = msg.value;
    }

    function _0x5f832b(uint256 _0xfce6c0) {
        require (!_0xb5d6ff);
        require(_0xfce6c0 < 10);
        msg.sender.transfer(_0x67cc31);
        _0xb5d6ff = true;
    }
}