// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address _0xc9bdce;
        uint _0xfa0dfd;
    }

    event RaffleResult(
        uint _0xfa0dfd,
        uint _0xc19dbd,
        address _0x39c6a0,
        address _0xc94005,
        address _0xb95520,
        uint _0xeac0a5,
        bytes32 _0x47a4c5
    );

    event TicketPurchase(
        uint _0xfa0dfd,
        address _0x7f4a39,
        uint number
    );

    event TicketRefund(
        uint _0xfa0dfd,
        address _0x7f4a39,
        uint number
    );

    // Constants
    uint public constant _0x5bd0c0 = 2.5 ether;
    uint public constant _0x0711dc = 0.03 ether;
    uint public constant _0x09321e = 50;
    uint public constant _0xea5b52 = (_0x5bd0c0 + _0x0711dc) / _0x09321e; // Make sure this divides evenly
    address _0xd0edaa;

    // Other internal variables
    bool public _0xcc0412 = false;
    uint public _0xfa0dfd = 1;
    uint public _0x44cac9 = block.number;
    uint _0x8afa12 = 0;
    mapping (uint => Contestant) _0x8579f7;
    uint[] _0x8c4782;

    // Initialization
    function Ethraffle_v4b() public {
        _0xd0edaa = msg.sender;
    }

    // Call buyTickets() when receiving Ether outside a function
    function () payable public {
        _0x9c0fb7();
    }

    function _0x9c0fb7() payable public {
        if (_0xcc0412) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint _0x726995 = msg.value;

        while (_0x726995 >= _0xea5b52 && _0x8afa12 < _0x09321e) {
            uint _0x8c5d3d = 0;
            if (_0x8c4782.length > 0) {
                _0x8c5d3d = _0x8c4782[_0x8c4782.length-1];
                _0x8c4782.length--;
            } else {
                _0x8c5d3d = _0x8afa12++;
            }

            _0x8579f7[_0x8c5d3d] = Contestant(msg.sender, _0xfa0dfd);
            TicketPurchase(_0xfa0dfd, msg.sender, _0x8c5d3d);
            _0x726995 -= _0xea5b52;
        }

        // Choose winner if we sold all the tickets
        if (_0x8afa12 == _0x09321e) {
            _0x6d8fb0();
        }

        // Send back leftover money
        if (_0x726995 > 0) {
            msg.sender.transfer(_0x726995);
        }
    }

    function _0x6d8fb0() private {
        address _0xc94005 = _0x8579f7[uint(block.coinbase) % _0x09321e]._0xc9bdce;
        address _0xb95520 = _0x8579f7[uint(msg.sender) % _0x09321e]._0xc9bdce;
        uint _0xeac0a5 = block.difficulty;
        bytes32 _0x47a4c5 = _0x4689b7(_0xc94005, _0xb95520, _0xeac0a5);

        uint _0xc19dbd = uint(_0x47a4c5) % _0x09321e;
        address _0x39c6a0 = _0x8579f7[_0xc19dbd]._0xc9bdce;
        RaffleResult(_0xfa0dfd, _0xc19dbd, _0x39c6a0, _0xc94005, _0xb95520, _0xeac0a5, _0x47a4c5);

        // Start next raffle
        _0xfa0dfd++;
        _0x8afa12 = 0;
        _0x44cac9 = block.number;

        // gaps.length = 0 isn't necessary here,
        // because buyTickets() eventually clears
        // the gaps array in the loop itself.

        // Distribute prize and fee
        _0x39c6a0.transfer(_0x5bd0c0);
        _0xd0edaa.transfer(_0x0711dc);
    }

    // Get your money back before the raffle occurs
    function _0x00d154() public {
        uint _0xa9f7b6 = 0;
        for (uint i = 0; i < _0x09321e; i++) {
            if (msg.sender == _0x8579f7[i]._0xc9bdce && _0xfa0dfd == _0x8579f7[i]._0xfa0dfd) {
                _0xa9f7b6 += _0xea5b52;
                _0x8579f7[i] = Contestant(address(0), 0);
                _0x8c4782.push(i);
                TicketRefund(_0xfa0dfd, msg.sender, i);
            }
        }

        if (_0xa9f7b6 > 0) {
            msg.sender.transfer(_0xa9f7b6);
        }
    }

    // Refund everyone's money, start a new raffle, then pause it
    function _0x9461a6() public {
        if (msg.sender == _0xd0edaa) {
            _0xcc0412 = true;

            for (uint i = 0; i < _0x09321e; i++) {
                if (_0xfa0dfd == _0x8579f7[i]._0xfa0dfd) {
                    TicketRefund(_0xfa0dfd, _0x8579f7[i]._0xc9bdce, i);
                    _0x8579f7[i]._0xc9bdce.transfer(_0xea5b52);
                }
            }

            RaffleResult(_0xfa0dfd, _0x09321e, address(0), address(0), address(0), 0, 0);
            _0xfa0dfd++;
            _0x8afa12 = 0;
            _0x44cac9 = block.number;
            _0x8c4782.length = 0;
        }
    }

    function _0xf3b59d() public {
        if (msg.sender == _0xd0edaa) {
            _0xcc0412 = !_0xcc0412;
        }
    }

    function _0x115027() public {
        if (msg.sender == _0xd0edaa) {
            selfdestruct(_0xd0edaa);
        }
    }
}