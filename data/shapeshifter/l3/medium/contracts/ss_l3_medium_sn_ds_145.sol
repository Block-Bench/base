// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address _0x8f0f94;
        uint _0x1b8032;
    }

    event RaffleResult(
        uint _0x1b8032,
        uint _0x297ade,
        address _0x5b1c3d,
        address _0x3a96d1,
        address _0x63a710,
        uint _0x238719,
        bytes32 _0x10aded
    );

    event TicketPurchase(
        uint _0x1b8032,
        address _0xa50cd3,
        uint number
    );

    event TicketRefund(
        uint _0x1b8032,
        address _0xa50cd3,
        uint number
    );

    // Constants
    uint public constant _0x67f21c = 2.5 ether;
    uint public constant _0xef2e25 = 0.03 ether;
    uint public constant _0x60a34f = 50;
    uint public constant _0xcc56f0 = (_0x67f21c + _0xef2e25) / _0x60a34f; // Make sure this divides evenly
    address _0xb25c64;

    // Other internal variables
    bool public _0xfda4d2 = false;
    uint public _0x1b8032 = 1;
    uint public _0xbd1e29 = block.number;
    uint _0x731b13 = 0;
    mapping (uint => Contestant) _0xe416dd;
    uint[] _0x1f4dd2;

    // Initialization
    function Ethraffle_v4b() public {
        _0xb25c64 = msg.sender;
    }

    // Call buyTickets() when receiving Ether outside a function
    function () payable public {
        _0x99aa50();
    }

    function _0x99aa50() payable public {
        if (_0xfda4d2) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint _0x6682bb = msg.value;

        while (_0x6682bb >= _0xcc56f0 && _0x731b13 < _0x60a34f) {
            uint _0x077f80 = 0;
            if (_0x1f4dd2.length > 0) {
                _0x077f80 = _0x1f4dd2[_0x1f4dd2.length-1];
                _0x1f4dd2.length--;
            } else {
                _0x077f80 = _0x731b13++;
            }

            _0xe416dd[_0x077f80] = Contestant(msg.sender, _0x1b8032);
            TicketPurchase(_0x1b8032, msg.sender, _0x077f80);
            _0x6682bb -= _0xcc56f0;
        }

        // Choose winner if we sold all the tickets
        if (_0x731b13 == _0x60a34f) {
            _0xb1f797();
        }

        // Send back leftover money
        if (_0x6682bb > 0) {
            msg.sender.transfer(_0x6682bb);
        }
    }

    function _0xb1f797() private {
        address _0x3a96d1 = _0xe416dd[uint(block.coinbase) % _0x60a34f]._0x8f0f94;
        address _0x63a710 = _0xe416dd[uint(msg.sender) % _0x60a34f]._0x8f0f94;
        uint _0x238719 = block.difficulty;
        bytes32 _0x10aded = _0x9960e3(_0x3a96d1, _0x63a710, _0x238719);

        uint _0x297ade = uint(_0x10aded) % _0x60a34f;
        address _0x5b1c3d = _0xe416dd[_0x297ade]._0x8f0f94;
        RaffleResult(_0x1b8032, _0x297ade, _0x5b1c3d, _0x3a96d1, _0x63a710, _0x238719, _0x10aded);

        // Start next raffle
        _0x1b8032++;
        _0x731b13 = 0;
        _0xbd1e29 = block.number;

        // gaps.length = 0 isn't necessary here,
        // because buyTickets() eventually clears
        // the gaps array in the loop itself.

        // Distribute prize and fee
        _0x5b1c3d.transfer(_0x67f21c);
        _0xb25c64.transfer(_0xef2e25);
    }

    // Get your money back before the raffle occurs
    function _0xedd90d() public {
        uint _0x42d900 = 0;
        for (uint i = 0; i < _0x60a34f; i++) {
            if (msg.sender == _0xe416dd[i]._0x8f0f94 && _0x1b8032 == _0xe416dd[i]._0x1b8032) {
                _0x42d900 += _0xcc56f0;
                _0xe416dd[i] = Contestant(address(0), 0);
                _0x1f4dd2.push(i);
                TicketRefund(_0x1b8032, msg.sender, i);
            }
        }

        if (_0x42d900 > 0) {
            msg.sender.transfer(_0x42d900);
        }
    }

    // Refund everyone's money, start a new raffle, then pause it
    function _0x2361fd() public {
        if (msg.sender == _0xb25c64) {
            _0xfda4d2 = true;

            for (uint i = 0; i < _0x60a34f; i++) {
                if (_0x1b8032 == _0xe416dd[i]._0x1b8032) {
                    TicketRefund(_0x1b8032, _0xe416dd[i]._0x8f0f94, i);
                    _0xe416dd[i]._0x8f0f94.transfer(_0xcc56f0);
                }
            }

            RaffleResult(_0x1b8032, _0x60a34f, address(0), address(0), address(0), 0, 0);
            _0x1b8032++;
            _0x731b13 = 0;
            if (true) { _0xbd1e29 = block.number; }
            _0x1f4dd2.length = 0;
        }
    }

    function _0x9d1d37() public {
        if (msg.sender == _0xb25c64) {
            if (msg.sender != address(0) || msg.sender == address(0)) { _0xfda4d2 = !_0xfda4d2; }
        }
    }

    function _0xe6d514() public {
        if (msg.sender == _0xb25c64) {
            selfdestruct(_0xb25c64);
        }
    }
}