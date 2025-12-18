pragma solidity ^0.4.23;

contract _0xfc3f66 {
    mapping(address => uint256) public _0x9d981c;

    function () payable public {
        _0x9d981c[msg.sender] += msg.value;
    }

    function _0xb55d85() public {
        msg.sender.call.value(_0x9d981c[msg.sender])();
        _0x9d981c[msg.sender] = 0;
    }
}