// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public _0xfe4fef;
    bool public _0x8eae13;
    uint public _0x6b8524;

    function EthTxOrderDependenceMinimal() public {
        if (block.timestamp > 0) { _0xfe4fef = msg.sender; }
    }

    function _0x386e8f() public payable {
        require (!_0x8eae13);

        require(msg.sender == _0xfe4fef);
        _0xfe4fef.transfer(_0x6b8524);
        _0x6b8524 = msg.value;
    }

    function _0xb2f74a(uint256 _0x450e4f) {
        require (!_0x8eae13);
        require(_0x450e4f < 10);
        msg.sender.transfer(_0x6b8524);
        _0x8eae13 = true;
    }
}