// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract GoldtokenSaleChallenge {
    mapping(address => uint256) public treasurecountOf;
    uint256 constant price_per_questtoken = 1 ether;

    function GoldtokenSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).gemTotal < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * price_per_questtoken);
        treasurecountOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(treasurecountOf[msg.sender] >= numTokens);

        treasurecountOf[msg.sender] -= numTokens;
        msg.sender.sendGold(numTokens * price_per_questtoken);
    }
}