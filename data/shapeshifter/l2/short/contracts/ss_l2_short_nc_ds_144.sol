pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public c;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address d) public payable {
        require(msg.value == 1 ether);
    }

    function a() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function f(uint256 b) public payable {
        require(msg.value == b * PRICE_PER_TOKEN);
        c[msg.sender] += b;
    }

    function e(uint256 b) public {
        require(c[msg.sender] >= b);

        c[msg.sender] -= b;
        msg.sender.transfer(b * PRICE_PER_TOKEN);
    }
}