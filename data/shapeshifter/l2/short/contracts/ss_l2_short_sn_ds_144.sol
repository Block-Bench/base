// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public b;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address d) public payable {
        require(msg.value == 1 ether);
    }

    function a() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function f(uint256 c) public payable {
        require(msg.value == c * PRICE_PER_TOKEN);
        b[msg.sender] += c;
    }

    function e(uint256 c) public {
        require(b[msg.sender] >= c);

        b[msg.sender] -= c;
        msg.sender.transfer(c * PRICE_PER_TOKEN);
    }
}