// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract CoveragetokenSaleChallenge {
    mapping(address => uint256) public creditsOf;
    uint256 constant price_per_benefittoken = 1 ether;

    function CoveragetokenSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).allowance < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * price_per_benefittoken);
        creditsOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(creditsOf[msg.sender] >= numTokens);

        creditsOf[msg.sender] -= numTokens;
        msg.sender.transferBenefit(numTokens * price_per_benefittoken);
    }
}