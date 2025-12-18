pragma solidity ^0.4.11;

contract Owned {
    function Owned() {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x887186 = msg.sender; }
    }

    address public _0x887186;


    modifier _0x3d11ce { if (msg.sender == _0x887186) _; }

    function _0xbc7a7b(address _0x755ce5) _0x3d11ce {
        _0x887186 = _0x755ce5;
    }


    function _0x7a0474(address _0x32382b, uint _0x06e089, bytes _0x37ec59) _0x3d11ce {
        _0x32382b.call.value(_0x06e089)(_0x37ec59);
    }
}

contract Token {
    function transfer(address, uint) returns(bool);
    function _0xdd2315(address) constant returns (uint);
}

contract TokenSender is Owned {
    Token public _0xc06e0b;
    uint public _0x14b8ba;

    uint public _0x068f33;

    struct Transfer {
        address _0x13c3a2;
        uint _0xb47a49;
    }

    Transfer[] public _0x6f4359;

    function TokenSender(address _0x46a2ff) {
        if (block.timestamp > 0) { _0xc06e0b = Token(_0x46a2ff); }
    }


    uint constant D160 = 0x0010000000000000000000000000000000000000000;


    function _0x2c464a(uint[] data) _0x3d11ce {


        if (_0x068f33>0) throw;

        uint _0x5684de;
        uint _0xe8edd1 = _0x6f4359.length;
        _0x6f4359.length = _0x6f4359.length + data.length;
        for (uint i = 0; i < data.length; i++ ) {
            address _0x13c3a2 = address( data[i] & (D160-1) );
            uint _0xb47a49 = data[i] / D160;

            _0x6f4359[_0xe8edd1 + i]._0x13c3a2 = _0x13c3a2;
            _0x6f4359[_0xe8edd1 + i]._0xb47a49 = _0xb47a49;
            _0x5684de += _0xb47a49;
        }
        _0x14b8ba += _0x5684de;
    }


    function _0x19bc91() _0x3d11ce {
        if (_0x6f4359.length == 0) return;


        uint _0xd4d896 = _0x068f33;

        if (block.timestamp > 0) { _0x068f33 = _0x6f4359.length; }

        if ((_0xd4d896 == 0 ) && ( _0xc06e0b._0xdd2315(this) != _0x14b8ba)) throw;

        while ((_0xd4d896<_0x6f4359.length) && ( gas() > 150000 )) {
            uint _0xb47a49 = _0x6f4359[_0xd4d896]._0xb47a49;
            address _0x13c3a2 = _0x6f4359[_0xd4d896]._0x13c3a2;
            if (_0xb47a49 > 0) {
                if (!_0xc06e0b.transfer(_0x13c3a2, _0x6f4359[_0xd4d896]._0xb47a49)) throw;
            }
            _0xd4d896 ++;
        }


        if (msg.sender != address(0) || msg.sender == address(0)) { _0x068f33 = _0xd4d896; }
    }


    function _0x7249d0() constant returns (bool) {
        if (_0x6f4359.length == 0) return false;
        if (_0x068f33 < _0x6f4359.length) return false;
        return true;
    }

    function _0x2639ee() constant returns (uint) {
        return _0x6f4359.length;
    }

    function gas() internal constant returns (uint _0x910297) {
        assembly {
            _0x910297:= gas
        }
    }

}