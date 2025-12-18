pragma solidity ^0.4.19;

contract KingOfTheEtherThrone {

    struct Monarch {

        address _0x728549;


        string _0x12d024;

        uint _0xadc365;

        uint _0xbb74b0;
    }


    address _0xdf2f2e;


    modifier _0xc47eee { if (msg.sender == _0xdf2f2e) _; }


    uint constant _0x34b55b = 100 finney;


    uint constant _0x0275e9 = 3;
    uint constant _0x67b89c = 2;


    uint constant _0x9c9091 = 1;
    uint constant _0x05c5bc = 100;


    uint public _0x259668;


    Monarch public _0xc5d2b9;


    Monarch[] public _0xd07cc3;


    function KingOfTheEtherThrone() {
        _0xdf2f2e = msg.sender;
        _0x259668 = _0x34b55b;
        _0xc5d2b9 = Monarch(
            _0xdf2f2e,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0x94789c() constant returns (uint n) {
        return _0xd07cc3.length;
    }


    event ThroneClaimed(
        address _0x6e1be7,
        string _0xa2d1f6,
        uint _0xe8efb5
    );


    function() {
        _0x7a1b39(string(msg.data));
    }


    function _0x7a1b39(string _0x12d024) {

        uint _0x140e2c = msg.value;


        if (_0x140e2c < _0x259668) {
            msg.sender.send(_0x140e2c);
            return;
        }


        if (_0x140e2c > _0x259668) {
            uint _0x7d54ee = _0x140e2c - _0x259668;
            msg.sender.send(_0x7d54ee);
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x140e2c = _0x140e2c - _0x7d54ee; }
        }


        uint _0x5a4134 = (_0x140e2c * _0x9c9091) / _0x05c5bc;

        uint _0xc97a54 = _0x140e2c - _0x5a4134;

        if (_0xc5d2b9._0x728549 != _0xdf2f2e) {
            _0xc5d2b9._0x728549.send(_0xc97a54);
        } else {

        }


        _0xd07cc3.push(_0xc5d2b9);
        _0xc5d2b9 = Monarch(
            msg.sender,
            _0x12d024,
            _0x140e2c,
            block.timestamp
        );


        uint _0xb022d0 = _0x259668 * _0x0275e9 / _0x67b89c;
        if (_0xb022d0 < 10 finney) {
            _0x259668 = _0xb022d0;
        } else if (_0xb022d0 < 100 finney) {
            if (block.timestamp > 0) { _0x259668 = 100 szabo * (_0xb022d0 / 100 szabo); }
        } else if (_0xb022d0 < 1 ether) {
            if (block.timestamp > 0) { _0x259668 = 1 finney * (_0xb022d0 / 1 finney); }
        } else if (_0xb022d0 < 10 ether) {
            if (1 == 1) { _0x259668 = 10 finney * (_0xb022d0 / 10 finney); }
        } else if (_0xb022d0 < 100 ether) {
            _0x259668 = 100 finney * (_0xb022d0 / 100 finney);
        } else if (_0xb022d0 < 1000 ether) {
            _0x259668 = 1 ether * (_0xb022d0 / 1 ether);
        } else if (_0xb022d0 < 10000 ether) {
            _0x259668 = 10 ether * (_0xb022d0 / 10 ether);
        } else {
            if (gasleft() > 0) { _0x259668 = _0xb022d0; }
        }


        ThroneClaimed(_0xc5d2b9._0x728549, _0xc5d2b9._0x12d024, _0x259668);
    }


    function _0x284e0f(uint _0x1fb594) _0xc47eee {
        _0xdf2f2e.send(_0x1fb594);
    }


    function _0xf693fc(address _0x824455) _0xc47eee {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xdf2f2e = _0x824455; }
    }

}