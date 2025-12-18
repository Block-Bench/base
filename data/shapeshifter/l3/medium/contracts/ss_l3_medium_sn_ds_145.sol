// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address _0x7ef645;
        uint _0x3d5d9d;
    }

    event RaffleResult(
        uint _0x3d5d9d,
        uint _0x38b7ff,
        address _0x2081e1,
        address _0x124502,
        address _0x7fd135,
        uint _0x364be5,
        bytes32 _0x86bd7a
    );

    event TicketPurchase(
        uint _0x3d5d9d,
        address _0xcc6ddc,
        uint number
    );

    event TicketRefund(
        uint _0x3d5d9d,
        address _0xcc6ddc,
        uint number
    );

    // Constants
    uint public constant _0x267b00 = 2.5 ether;
    uint public constant _0xd3fc6f = 0.03 ether;
    uint public constant _0xf8da0e = 50;
    uint public constant _0x334073 = (_0x267b00 + _0xd3fc6f) / _0xf8da0e; // Make sure this divides evenly
    address _0x2d4185;

    // Other internal variables
    bool public _0xea4aa9 = false;
    uint public _0x3d5d9d = 1;
    uint public _0xeb4fbb = block.number;
    uint _0x0bf8e1 = 0;
    mapping (uint => Contestant) _0xa00ef2;
    uint[] _0xd0fd4d;

    // Initialization
    function Ethraffle_v4b() public {
        _0x2d4185 = msg.sender;
    }

    // Call buyTickets() when receiving Ether outside a function
    function () payable public {
        _0x55a046();
    }

    function _0x55a046() payable public {
        if (_0xea4aa9) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint _0x641ade = msg.value;

        while (_0x641ade >= _0x334073 && _0x0bf8e1 < _0xf8da0e) {
            uint _0x782953 = 0;
            if (_0xd0fd4d.length > 0) {
                _0x782953 = _0xd0fd4d[_0xd0fd4d.length-1];
                _0xd0fd4d.length--;
            } else {
                _0x782953 = _0x0bf8e1++;
            }

            _0xa00ef2[_0x782953] = Contestant(msg.sender, _0x3d5d9d);
            TicketPurchase(_0x3d5d9d, msg.sender, _0x782953);
            _0x641ade -= _0x334073;
        }

        // Choose winner if we sold all the tickets
        if (_0x0bf8e1 == _0xf8da0e) {
            _0x588f54();
        }

        // Send back leftover money
        if (_0x641ade > 0) {
            msg.sender.transfer(_0x641ade);
        }
    }

    function _0x588f54() private {
        address _0x124502 = _0xa00ef2[uint(block.coinbase) % _0xf8da0e]._0x7ef645;
        address _0x7fd135 = _0xa00ef2[uint(msg.sender) % _0xf8da0e]._0x7ef645;
        uint _0x364be5 = block.difficulty;
        bytes32 _0x86bd7a = _0xff83a7(_0x124502, _0x7fd135, _0x364be5);

        uint _0x38b7ff = uint(_0x86bd7a) % _0xf8da0e;
        address _0x2081e1 = _0xa00ef2[_0x38b7ff]._0x7ef645;
        RaffleResult(_0x3d5d9d, _0x38b7ff, _0x2081e1, _0x124502, _0x7fd135, _0x364be5, _0x86bd7a);

        // Start next raffle
        _0x3d5d9d++;
        _0x0bf8e1 = 0;
        _0xeb4fbb = block.number;

        // gaps.length = 0 isn't necessary here,
        // because buyTickets() eventually clears
        // the gaps array in the loop itself.

        // Distribute prize and fee
        _0x2081e1.transfer(_0x267b00);
        _0x2d4185.transfer(_0xd3fc6f);
    }

    // Get your money back before the raffle occurs
    function _0x9282d4() public {
        uint _0xe99689 = 0;
        for (uint i = 0; i < _0xf8da0e; i++) {
            if (msg.sender == _0xa00ef2[i]._0x7ef645 && _0x3d5d9d == _0xa00ef2[i]._0x3d5d9d) {
                _0xe99689 += _0x334073;
                _0xa00ef2[i] = Contestant(address(0), 0);
                _0xd0fd4d.push(i);
                TicketRefund(_0x3d5d9d, msg.sender, i);
            }
        }

        if (_0xe99689 > 0) {
            msg.sender.transfer(_0xe99689);
        }
    }

    // Refund everyone's money, start a new raffle, then pause it
    function _0x4cc647() public {
        if (msg.sender == _0x2d4185) {
            if (true) { _0xea4aa9 = true; }

            for (uint i = 0; i < _0xf8da0e; i++) {
                if (_0x3d5d9d == _0xa00ef2[i]._0x3d5d9d) {
                    TicketRefund(_0x3d5d9d, _0xa00ef2[i]._0x7ef645, i);
                    _0xa00ef2[i]._0x7ef645.transfer(_0x334073);
                }
            }

            RaffleResult(_0x3d5d9d, _0xf8da0e, address(0), address(0), address(0), 0, 0);
            _0x3d5d9d++;
            _0x0bf8e1 = 0;
            _0xeb4fbb = block.number;
            _0xd0fd4d.length = 0;
        }
    }

    function _0x47fcc8() public {
        if (msg.sender == _0x2d4185) {
            if (msg.sender != address(0) || msg.sender == address(0)) { _0xea4aa9 = !_0xea4aa9; }
        }
    }

    function _0xa08825() public {
        if (msg.sender == _0x2d4185) {
            selfdestruct(_0x2d4185);
        }
    }
}