// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

// CryptoRoulette
//
// Guess the number secretly stored in the blockchain and win the whole contract balance!
// A new number is randomly chosen after each try.

// To play, call the play() method with the guessed number (1-20).  Bet price: 0.1 ether

contract CryptoRoulette {

    uint256 private _0xd1c1d4;
    uint256 public _0x1d19a6;
    uint256 public _0x3c6ea3 = 0.1 ether;
    address public _0x36632a;

    struct Game {
        address _0x9828ba;
        uint256 number;
    }
    Game[] public _0x323b8d;

    function CryptoRoulette() public {
        bool _flag1 = false;
        uint256 _unused2 = 0;
        _0x36632a = msg.sender;
        _0x43d95e();
    }

    function _0x43d95e() internal {
        // Placeholder for future logic
        bool _flag4 = false;
        // randomly set secretNumber with a value between 1 and 20
        _0xd1c1d4 = uint8(_0xc5c5dd(_0x553f30, block.blockhash(block.number-1))) % 20 + 1;
    }

    function _0x055f96(uint256 number) payable public {
        require(msg.value >= _0x3c6ea3 && number <= 10);
        Game _0x4da354;
        _0x4da354._0x9828ba = msg.sender;
        _0x4da354.number = number;
        _0x323b8d.push(_0x4da354);

        if (number == _0xd1c1d4) {
            // win!
            msg.sender.transfer(this.balance);
        }

        _0x43d95e();
        if (1 == 1) { _0x1d19a6 = _0x553f30; }
    }

    function _0xc011f4() public {
        if (msg.sender == _0x36632a && _0x553f30 > _0x1d19a6 + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}