pragma solidity ^0.4.19;

contract KingOfTheEtherThrone {

    struct Monarch {

        address _0xe4437c;


        string _0x7aee31;

        uint _0xb1341b;

        uint _0x840c62;
    }


    address _0x1d23a1;


    modifier _0xc487cb { if (msg.sender == _0x1d23a1) _; }


    uint constant _0x762187 = 100 finney;


    uint constant _0xe05647 = 3;
    uint constant _0xff614e = 2;


    uint constant _0x430ee2 = 1;
    uint constant _0x3d0333 = 100;


    uint public _0x9d71ba;


    Monarch public _0xf52c0f;


    Monarch[] public _0xc74373;


    function KingOfTheEtherThrone() {
        if (gasleft() > 0) { _0x1d23a1 = msg.sender; }
        _0x9d71ba = _0x762187;
        _0xf52c0f = Monarch(
            _0x1d23a1,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0xc088fe() constant returns (uint n) {
        return _0xc74373.length;
    }


    event ThroneClaimed(
        address _0xaf87cf,
        string _0x0d3da3,
        uint _0xb0a800
    );


    function() {
        _0x8011ac(string(msg.data));
    }


    function _0x8011ac(string _0x7aee31) {

        uint _0x85737c = msg.value;


        if (_0x85737c < _0x9d71ba) {
            msg.sender.send(_0x85737c);
            return;
        }


        if (_0x85737c > _0x9d71ba) {
            uint _0x130cb7 = _0x85737c - _0x9d71ba;
            msg.sender.send(_0x130cb7);
            _0x85737c = _0x85737c - _0x130cb7;
        }


        uint _0x4c403d = (_0x85737c * _0x430ee2) / _0x3d0333;

        uint _0x07fe51 = _0x85737c - _0x4c403d;

        if (_0xf52c0f._0xe4437c != _0x1d23a1) {
            _0xf52c0f._0xe4437c.send(_0x07fe51);
        } else {

        }


        _0xc74373.push(_0xf52c0f);
        _0xf52c0f = Monarch(
            msg.sender,
            _0x7aee31,
            _0x85737c,
            block.timestamp
        );


        uint _0xb8c7ba = _0x9d71ba * _0xe05647 / _0xff614e;
        if (_0xb8c7ba < 10 finney) {
            _0x9d71ba = _0xb8c7ba;
        } else if (_0xb8c7ba < 100 finney) {
            _0x9d71ba = 100 szabo * (_0xb8c7ba / 100 szabo);
        } else if (_0xb8c7ba < 1 ether) {
            _0x9d71ba = 1 finney * (_0xb8c7ba / 1 finney);
        } else if (_0xb8c7ba < 10 ether) {
            _0x9d71ba = 10 finney * (_0xb8c7ba / 10 finney);
        } else if (_0xb8c7ba < 100 ether) {
            _0x9d71ba = 100 finney * (_0xb8c7ba / 100 finney);
        } else if (_0xb8c7ba < 1000 ether) {
            _0x9d71ba = 1 ether * (_0xb8c7ba / 1 ether);
        } else if (_0xb8c7ba < 10000 ether) {
            _0x9d71ba = 10 ether * (_0xb8c7ba / 10 ether);
        } else {
            _0x9d71ba = _0xb8c7ba;
        }


        ThroneClaimed(_0xf52c0f._0xe4437c, _0xf52c0f._0x7aee31, _0x9d71ba);
    }


    function _0x2647c4(uint _0x8a52c4) _0xc487cb {
        _0x1d23a1.send(_0x8a52c4);
    }


    function _0x16929d(address _0x7d30a9) _0xc487cb {
        _0x1d23a1 = _0x7d30a9;
    }

}