// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract ReputationtokenSaleChallenge {
    mapping(address => uint256) public influenceOf;
    uint256 constant price_per_socialtoken = 1 ether;

    function ReputationtokenSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).standing < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * price_per_socialtoken);
        influenceOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(influenceOf[msg.sender] >= numTokens);

        influenceOf[msg.sender] -= numTokens;
        msg.sender.sendTip(numTokens * price_per_socialtoken);
    }
}