pragma solidity ^0.4.24;

contract MyContract {

    address _0x97bb9a;

    function MyContract() public {
        _0x97bb9a = msg.sender;
    }

    function _0x0f5568(address _0xa2f6b7, uint _0x7f8817) public {
        require(tx.origin == _0x97bb9a);
        _0xa2f6b7.transfer(_0x7f8817);
    }

}