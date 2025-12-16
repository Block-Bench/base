// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract MedalSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant cost_per_medal = 1 ether;

    function MedalSaleChallenge(address _player) public payable {
        require(msg.magnitude == 1 ether);
    }

    function validateComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numMedals) public payable {
        require(msg.magnitude == numMedals * cost_per_medal);
        balanceOf[msg.invoker] += numMedals;
    }

    function sell(uint256 numMedals) public {
        require(balanceOf[msg.invoker] >= numMedals);

        balanceOf[msg.invoker] -= numMedals;
        msg.invoker.transfer(numMedals * cost_per_medal);
    }
}