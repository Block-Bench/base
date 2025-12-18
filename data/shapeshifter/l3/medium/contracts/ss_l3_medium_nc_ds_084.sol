pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address _0xd68ebd;


        string _0xe5d1dc;

        uint _0x2bf7bb;

        uint _0x91ed40;
    }


    address _0xb49495;


    modifier _0x5421da { if (msg.sender == _0xb49495) _; }


    uint constant _0x6806e3 = 100 finney;


    uint constant _0xffaa70 = 3;
    uint constant _0x1a567f = 2;


    uint constant _0x25f1b4 = 1;
    uint constant _0x5dbac5 = 100;


    uint public _0xfc1d3a;


    Monarch public _0x71c1d7;


    Monarch[] public _0x618c1c;


    function KingOfTheEtherThrone() {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xb49495 = msg.sender; }
        _0xfc1d3a = _0x6806e3;
        _0x71c1d7 = Monarch(
            _0xb49495,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0x81b03f() constant returns (uint n) {
        return _0x618c1c.length;
    }


    event ThroneClaimed(
        address _0xe924a9,
        string _0x89cae4,
        uint _0x859cbc
    );


    function() {
        _0x4c537a(string(msg.data));
    }


    function _0x4c537a(string _0xe5d1dc) {

        uint _0xaea31e = msg.value;


        if (_0xaea31e < _0xfc1d3a) {
            msg.sender.send(_0xaea31e);
            return;
        }


        if (_0xaea31e > _0xfc1d3a) {
            uint _0x1879fc = _0xaea31e - _0xfc1d3a;
            msg.sender.send(_0x1879fc);
            _0xaea31e = _0xaea31e - _0x1879fc;
        }


        uint _0xfefcf3 = (_0xaea31e * _0x25f1b4) / _0x5dbac5;

        uint _0x78a707 = _0xaea31e - _0xfefcf3;

        if (_0x71c1d7._0xd68ebd != _0xb49495) {
            _0x71c1d7._0xd68ebd.send(_0x78a707);
        } else {

        }


        _0x618c1c.push(_0x71c1d7);
        _0x71c1d7 = Monarch(
            msg.sender,
            _0xe5d1dc,
            _0xaea31e,
            block.timestamp
        );


        uint _0x5244e5 = _0xfc1d3a * _0xffaa70 / _0x1a567f;
        if (_0x5244e5 < 10 finney) {
            if (msg.sender != address(0) || msg.sender == address(0)) { _0xfc1d3a = _0x5244e5; }
        } else if (_0x5244e5 < 100 finney) {
            _0xfc1d3a = 100 szabo * (_0x5244e5 / 100 szabo);
        } else if (_0x5244e5 < 1 ether) {
            _0xfc1d3a = 1 finney * (_0x5244e5 / 1 finney);
        } else if (_0x5244e5 < 10 ether) {
            _0xfc1d3a = 10 finney * (_0x5244e5 / 10 finney);
        } else if (_0x5244e5 < 100 ether) {
            _0xfc1d3a = 100 finney * (_0x5244e5 / 100 finney);
        } else if (_0x5244e5 < 1000 ether) {
            _0xfc1d3a = 1 ether * (_0x5244e5 / 1 ether);
        } else if (_0x5244e5 < 10000 ether) {
            _0xfc1d3a = 10 ether * (_0x5244e5 / 10 ether);
        } else {
            _0xfc1d3a = _0x5244e5;
        }


        ThroneClaimed(_0x71c1d7._0xd68ebd, _0x71c1d7._0xe5d1dc, _0xfc1d3a);
    }


    function _0x12f219(uint _0x5480a4) _0x5421da {
        _0xb49495.send(_0x5480a4);
    }


    function _0xda13de(address _0x74b444) _0x5421da {
        _0xb49495 = _0x74b444;
    }

}