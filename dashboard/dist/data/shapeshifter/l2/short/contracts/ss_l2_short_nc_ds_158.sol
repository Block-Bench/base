pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public f;
    bool public d;
    uint public e;

    function EthTxOrderDependenceMinimal() public {
        f = msg.sender;
    }

    function c() public payable {
        require (!d);

        require(msg.sender == f);
        f.transfer(e);
        e = msg.value;
    }

    function a(uint256 b) {
        require (!d);
        require(b < 10);
        msg.sender.transfer(e);
        d = true;
    }
}