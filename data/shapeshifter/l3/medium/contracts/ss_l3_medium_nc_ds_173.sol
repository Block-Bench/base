pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        _0xedc3da = msg.sender;
    }

    address public _0xedc3da;


    modifier _0x21ca8b { if (msg.sender == _0xedc3da) _; }

    function _0xfeef4c(address _0xa4674b) _0x21ca8b {
        _0xedc3da = _0xa4674b;
    }


    function _0x58efbf(address _0x287088, uint _0xf075de, bytes _0xdc5352) _0x21ca8b {
        _0x287088.call.value(_0xf075de)(_0xdc5352);
    }
}

contract Token {
    function transfer(address, uint) returns(bool);
    function _0x63a6c1(address) constant returns (uint);
}

contract TokenSender is Owned {
    Token public _0xa97ae5;
    uint public _0x9e06a7;

    uint public _0x70332a;

    struct Transfer {
        address _0xbb3e5b;
        uint _0xdea227;
    }

    Transfer[] public _0xfc630b;

    function TokenSender(address _0xffd2d0) {
        _0xa97ae5 = Token(_0xffd2d0);
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function _0xd11975(uint[] data) _0x21ca8b {


        if (_0x70332a>0) throw;

        uint _0xc610a8;
        uint _0xfcaae6 = _0xfc630b.length;
        _0xfc630b.length = _0xfc630b.length + data.length;
        for (uint i = 0; i < data.length; i++ ) {
            address _0xbb3e5b = address( data[i] & (D160-1) );
            uint _0xdea227 = data[i] / D160;

            _0xfc630b[_0xfcaae6 + i]._0xbb3e5b = _0xbb3e5b;
            _0xfc630b[_0xfcaae6 + i]._0xdea227 = _0xdea227;
            _0xc610a8 += _0xdea227;
        }
        _0x9e06a7 += _0xc610a8;
    }


    function _0x6d0bed() _0x21ca8b {
        if (_0xfc630b.length == 0) return;


        uint _0xa125e6 = _0x70332a;

        _0x70332a = _0xfc630b.length;

        if ((_0xa125e6 == 0 ) && ( _0xa97ae5._0x63a6c1(this) != _0x9e06a7)) throw;

        while ((_0xa125e6<_0xfc630b.length) && ( gas() > 150000 )) {
            uint _0xdea227 = _0xfc630b[_0xa125e6]._0xdea227;
            address _0xbb3e5b = _0xfc630b[_0xa125e6]._0xbb3e5b;
            if (_0xdea227 > 0) {
                if (!_0xa97ae5.transfer(_0xbb3e5b, _0xfc630b[_0xa125e6]._0xdea227)) throw;
            }
            _0xa125e6 ++;
        }


        _0x70332a = _0xa125e6;
    }


    function _0xf89246() constant returns (bool) {
        if (_0xfc630b.length == 0) return false;
        if (_0x70332a < _0xfc630b.length) return false;
        return true;
    }

    function _0x241a9b() constant returns (uint) {
        return _0xfc630b.length;
    }

    function gas() internal constant returns (uint _0x4701dc) {
        assembly {
            _0x4701dc:= gas
        }
    }

}