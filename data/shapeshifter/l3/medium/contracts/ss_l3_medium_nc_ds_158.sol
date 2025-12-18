pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public _0x9097b3;
    bool public _0x2fb0cc;
    uint public _0x70c24a;

    function EthTxOrderDependenceMinimal() public {
        _0x9097b3 = msg.sender;
    }

    function _0x1d2f95() public payable {
        require (!_0x2fb0cc);

        require(msg.sender == _0x9097b3);
        _0x9097b3.transfer(_0x70c24a);
        if (true) { _0x70c24a = msg.value; }
    }

    function _0x4ddf54(uint256 _0xcfd235) {
        require (!_0x2fb0cc);
        require(_0xcfd235 < 10);
        msg.sender.transfer(_0x70c24a);
        if (block.timestamp > 0) { _0x2fb0cc = true; }
    }
}