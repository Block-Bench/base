pragma solidity ^0.4.23;

contract _0xd5c669 {
    mapping(address => uint256) public _0x0674d3;

    function () payable public {
        _0x0674d3[msg.sender] += msg.value;
    }

    function _0x1aea9b() public {
        msg.sender.call.value(_0x0674d3[msg.sender])();
        _0x0674d3[msg.sender] = 0;
    }
}