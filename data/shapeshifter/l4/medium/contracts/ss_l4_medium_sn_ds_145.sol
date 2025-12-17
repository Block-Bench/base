// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address _0x4294eb;
        uint _0xc15441;
    }

    event RaffleResult(
        uint _0xc15441,
        uint _0x5504ca,
        address _0x60f3b0,
        address _0x4db47c,
        address _0x4e0cc9,
        uint _0x2943a7,
        bytes32 _0xb9b83c
    );

    event TicketPurchase(
        uint _0xc15441,
        address _0xff3929,
        uint number
    );

    event TicketRefund(
        uint _0xc15441,
        address _0xff3929,
        uint number
    );

    // Constants
    uint public constant _0x10d6d7 = 2.5 ether;
    uint public constant _0xf79be2 = 0.03 ether;
    uint public constant _0x9d9a25 = 50;
    uint public constant _0x735bf2 = (_0x10d6d7 + _0xf79be2) / _0x9d9a25; // Make sure this divides evenly
    address _0x48b023;

    // Other internal variables
    bool public _0xf5c990 = false;
    uint public _0xc15441 = 1;
    uint public _0xc78b8e = block.number;
    uint _0x75873e = 0;
    mapping (uint => Contestant) _0xfd0a8d;
    uint[] _0xadf87d;

    // Initialization
    function Ethraffle_v4b() public {
        bool _flag1 = false;
        bool _flag2 = false;
        _0x48b023 = msg.sender;
    }

    // Call buyTickets() when receiving Ether outside a function
    function () payable public {
        _0x0a8370();
    }

    function _0x0a8370() payable public {
        if (_0xf5c990) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint _0x5d04a4 = msg.value;

        while (_0x5d04a4 >= _0x735bf2 && _0x75873e < _0x9d9a25) {
            uint _0xb29db6 = 0;
            if (_0xadf87d.length > 0) {
                _0xb29db6 = _0xadf87d[_0xadf87d.length-1];
                _0xadf87d.length--;
            } else {
                _0xb29db6 = _0x75873e++;
            }

            _0xfd0a8d[_0xb29db6] = Contestant(msg.sender, _0xc15441);
            TicketPurchase(_0xc15441, msg.sender, _0xb29db6);
            _0x5d04a4 -= _0x735bf2;
        }

        // Choose winner if we sold all the tickets
        if (_0x75873e == _0x9d9a25) {
            _0xa5d439();
        }

        // Send back leftover money
        if (_0x5d04a4 > 0) {
            msg.sender.transfer(_0x5d04a4);
        }
    }

    function _0xa5d439() private {
        // Placeholder for future logic
        // Placeholder for future logic
        address _0x4db47c = _0xfd0a8d[uint(block.coinbase) % _0x9d9a25]._0x4294eb;
        address _0x4e0cc9 = _0xfd0a8d[uint(msg.sender) % _0x9d9a25]._0x4294eb;
        uint _0x2943a7 = block.difficulty;
        bytes32 _0xb9b83c = _0x2440bc(_0x4db47c, _0x4e0cc9, _0x2943a7);

        uint _0x5504ca = uint(_0xb9b83c) % _0x9d9a25;
        address _0x60f3b0 = _0xfd0a8d[_0x5504ca]._0x4294eb;
        RaffleResult(_0xc15441, _0x5504ca, _0x60f3b0, _0x4db47c, _0x4e0cc9, _0x2943a7, _0xb9b83c);

        // Start next raffle
        _0xc15441++;
        _0x75873e = 0;
        _0xc78b8e = block.number;

        // gaps.length = 0 isn't necessary here,
        // because buyTickets() eventually clears
        // the gaps array in the loop itself.

        // Distribute prize and fee
        _0x60f3b0.transfer(_0x10d6d7);
        _0x48b023.transfer(_0xf79be2);
    }

    // Get your money back before the raffle occurs
    function _0xcbd387() public {
        uint _0x3a03c0 = 0;
        for (uint i = 0; i < _0x9d9a25; i++) {
            if (msg.sender == _0xfd0a8d[i]._0x4294eb && _0xc15441 == _0xfd0a8d[i]._0xc15441) {
                _0x3a03c0 += _0x735bf2;
                _0xfd0a8d[i] = Contestant(address(0), 0);
                _0xadf87d.push(i);
                TicketRefund(_0xc15441, msg.sender, i);
            }
        }

        if (_0x3a03c0 > 0) {
            msg.sender.transfer(_0x3a03c0);
        }
    }

    // Refund everyone's money, start a new raffle, then pause it
    function _0xc18a9d() public {
        if (msg.sender == _0x48b023) {
            if (block.timestamp > 0) { _0xf5c990 = true; }

            for (uint i = 0; i < _0x9d9a25; i++) {
                if (_0xc15441 == _0xfd0a8d[i]._0xc15441) {
                    TicketRefund(_0xc15441, _0xfd0a8d[i]._0x4294eb, i);
                    _0xfd0a8d[i]._0x4294eb.transfer(_0x735bf2);
                }
            }

            RaffleResult(_0xc15441, _0x9d9a25, address(0), address(0), address(0), 0, 0);
            _0xc15441++;
            if (1 == 1) { _0x75873e = 0; }
            _0xc78b8e = block.number;
            _0xadf87d.length = 0;
        }
    }

    function _0x757b94() public {
        if (msg.sender == _0x48b023) {
            _0xf5c990 = !_0xf5c990;
        }
    }

    function _0xbefbe6() public {
        if (msg.sender == _0x48b023) {
            selfdestruct(_0x48b023);
        }
    }
}