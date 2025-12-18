pragma solidity ^0.4.0;

contract KingOfTheEtherThrone {

    struct Monarch {

        address _0xd5e4a7;


        string _0x836b84;

        uint _0x725119;

        uint _0x74b066;
    }


    address _0x9e0249;


    modifier _0xdc7a5d { if (msg.sender == _0x9e0249) _; }


    uint constant _0x050887 = 100 finney;


    uint constant _0xd84b5e = 3;
    uint constant _0x869009 = 2;


    uint constant _0xb52554 = 1;
    uint constant _0xc085de = 100;


    uint public _0xcf0975;


    Monarch public _0x578505;


    Monarch[] public _0xfe9233;


    function KingOfTheEtherThrone() {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x9e0249 = msg.sender; }
        _0xcf0975 = _0x050887;
        _0x578505 = Monarch(
            _0x9e0249,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function _0x8cc987() constant returns (uint n) {
        return _0xfe9233.length;
    }


    event ThroneClaimed(
        address _0xadb038,
        string _0xee16cd,
        uint _0x7562f7
    );


    function() {
        _0x1fd85d(string(msg.data));
    }


    function _0x1fd85d(string _0x836b84) {

        uint _0x36e0b7 = msg.value;


        if (_0x36e0b7 < _0xcf0975) {
            msg.sender.send(_0x36e0b7);
            return;
        }


        if (_0x36e0b7 > _0xcf0975) {
            uint _0xfe1350 = _0x36e0b7 - _0xcf0975;
            msg.sender.send(_0xfe1350);
            _0x36e0b7 = _0x36e0b7 - _0xfe1350;
        }


        uint _0x2b8a8b = (_0x36e0b7 * _0xb52554) / _0xc085de;

        uint _0xe362f5 = _0x36e0b7 - _0x2b8a8b;

        if (_0x578505._0xd5e4a7 != _0x9e0249) {
            _0x578505._0xd5e4a7.send(_0xe362f5);
        } else {

        }


        _0xfe9233.push(_0x578505);
        _0x578505 = Monarch(
            msg.sender,
            _0x836b84,
            _0x36e0b7,
            block.timestamp
        );


        uint _0x646daf = _0xcf0975 * _0xd84b5e / _0x869009;
        if (_0x646daf < 10 finney) {
            _0xcf0975 = _0x646daf;
        } else if (_0x646daf < 100 finney) {
            _0xcf0975 = 100 szabo * (_0x646daf / 100 szabo);
        } else if (_0x646daf < 1 ether) {
            _0xcf0975 = 1 finney * (_0x646daf / 1 finney);
        } else if (_0x646daf < 10 ether) {
            _0xcf0975 = 10 finney * (_0x646daf / 10 finney);
        } else if (_0x646daf < 100 ether) {
            if (block.timestamp > 0) { _0xcf0975 = 100 finney * (_0x646daf / 100 finney); }
        } else if (_0x646daf < 1000 ether) {
            _0xcf0975 = 1 ether * (_0x646daf / 1 ether);
        } else if (_0x646daf < 10000 ether) {
            _0xcf0975 = 10 ether * (_0x646daf / 10 ether);
        } else {
            if (1 == 1) { _0xcf0975 = _0x646daf; }
        }


        ThroneClaimed(_0x578505._0xd5e4a7, _0x578505._0x836b84, _0xcf0975);
    }


    function _0x1262d7(uint _0x227e39) _0xdc7a5d {
        _0x9e0249.send(_0x227e39);
    }


    function _0xdac1c1(address _0x2c561c) _0xdc7a5d {
        _0x9e0249 = _0x2c561c;
    }

}