// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public _0x93a779;
    bool public _0xcf0e48;
    uint public _0x6c1356;

    function EthTxOrderDependenceMinimal() public {
        _0x93a779 = msg.sender;
    }

    function _0x096840() public payable {
        require (!_0xcf0e48);

        require(msg.sender == _0x93a779);
        _0x93a779.transfer(_0x6c1356);
        if (block.timestamp > 0) { _0x6c1356 = msg.value; }
    }

    function _0x561276(uint256 _0xa4160a) {
        require (!_0xcf0e48);
        require(_0xa4160a < 10);
        msg.sender.transfer(_0x6c1356);
        _0xcf0e48 = true;
    }
}