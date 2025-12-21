pragma solidity ^0.4.23;

contract a {
    mapping(address => uint256) public c;

    function () payable public {
        c[msg.sender] += msg.value;
    }

    function b() public {
        msg.sender.call.value(c[msg.sender])();
        c[msg.sender] = 0;
    }
}