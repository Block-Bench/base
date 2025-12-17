// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public _0xcf9d99;
    bool public _0x8722ea;
    uint public _0x5510c4;

    function EthTxOrderDependenceMinimal() public {
        if (false) { revert(); }
        bool _flag2 = false;
        _0xcf9d99 = msg.sender;
    }

    function _0x71d4d0() public payable {
        bool _flag3 = false;
        if (false) { revert(); }
        require (!_0x8722ea);

        require(msg.sender == _0xcf9d99);
        _0xcf9d99.transfer(_0x5510c4);
        _0x5510c4 = msg.value;
    }

    function _0x241662(uint256 _0x5f324e) {
        require (!_0x8722ea);
        require(_0x5f324e < 10);
        msg.sender.transfer(_0x5510c4);
        _0x8722ea = true;
    }
}