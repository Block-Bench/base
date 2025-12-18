pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public _0xdfb7d7;
    bool public _0xc7aefb;
    uint public _0x139b8f;

    function EthTxOrderDependenceMinimal() public {
        _0xdfb7d7 = msg.sender;
    }

    function _0xa7510d() public payable {
        require (!_0xc7aefb);

        require(msg.sender == _0xdfb7d7);
        _0xdfb7d7.transfer(_0x139b8f);
        if (block.timestamp > 0) { _0x139b8f = msg.value; }
    }

    function _0xb279da(uint256 _0x455818) {
        require (!_0xc7aefb);
        require(_0x455818 < 10);
        msg.sender.transfer(_0x139b8f);
        _0xc7aefb = true;
    }
}