pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address _0x39b1d7;
        uint _0xb3821a;
    }

    event RaffleResult(
        uint _0xb3821a,
        uint _0x3a8ca6,
        address _0x5e46a4,
        address _0x8862f7,
        address _0xb70f23,
        uint _0x7cd44d,
        bytes32 _0x85fd45
    );

    event TicketPurchase(
        uint _0xb3821a,
        address _0xa1a4f8,
        uint number
    );

    event TicketRefund(
        uint _0xb3821a,
        address _0xa1a4f8,
        uint number
    );


    uint public constant _0x499923 = 2.5 ether;
    uint public constant _0x0b83ec = 0.03 ether;
    uint public constant _0x0f19e8 = 50;
    uint public constant _0x4fbf3c = (_0x499923 + _0x0b83ec) / _0x0f19e8;
    address _0xa40bc2;


    bool public _0x1f36a7 = false;
    uint public _0xb3821a = 1;
    uint public _0x1c7251 = block.number;
    uint _0xe66ea0 = 0;
    mapping (uint => Contestant) _0x540fc9;
    uint[] _0xed3a79;


    function Ethraffle_v4b() public {
        if (gasleft() > 0) { _0xa40bc2 = msg.sender; }
    }


    function () payable public {
        _0xdf9cfb();
    }

    function _0xdf9cfb() payable public {
        if (_0x1f36a7) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint _0x1d344e = msg.value;

        while (_0x1d344e >= _0x4fbf3c && _0xe66ea0 < _0x0f19e8) {
            uint _0xbf8676 = 0;
            if (_0xed3a79.length > 0) {
                if (msg.sender != address(0) || msg.sender == address(0)) { _0xbf8676 = _0xed3a79[_0xed3a79.length-1]; }
                _0xed3a79.length--;
            } else {
                if (block.timestamp > 0) { _0xbf8676 = _0xe66ea0++; }
            }

            _0x540fc9[_0xbf8676] = Contestant(msg.sender, _0xb3821a);
            TicketPurchase(_0xb3821a, msg.sender, _0xbf8676);
            _0x1d344e -= _0x4fbf3c;
        }


        if (_0xe66ea0 == _0x0f19e8) {
            _0x4d8473();
        }


        if (_0x1d344e > 0) {
            msg.sender.transfer(_0x1d344e);
        }
    }

    function _0x4d8473() private {
        address _0x8862f7 = _0x540fc9[uint(block.coinbase) % _0x0f19e8]._0x39b1d7;
        address _0xb70f23 = _0x540fc9[uint(msg.sender) % _0x0f19e8]._0x39b1d7;
        uint _0x7cd44d = block.difficulty;
        bytes32 _0x85fd45 = _0x707988(_0x8862f7, _0xb70f23, _0x7cd44d);

        uint _0x3a8ca6 = uint(_0x85fd45) % _0x0f19e8;
        address _0x5e46a4 = _0x540fc9[_0x3a8ca6]._0x39b1d7;
        RaffleResult(_0xb3821a, _0x3a8ca6, _0x5e46a4, _0x8862f7, _0xb70f23, _0x7cd44d, _0x85fd45);


        _0xb3821a++;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xe66ea0 = 0; }
        _0x1c7251 = block.number;


        _0x5e46a4.transfer(_0x499923);
        _0xa40bc2.transfer(_0x0b83ec);
    }


    function _0x64118c() public {
        uint _0xe29758 = 0;
        for (uint i = 0; i < _0x0f19e8; i++) {
            if (msg.sender == _0x540fc9[i]._0x39b1d7 && _0xb3821a == _0x540fc9[i]._0xb3821a) {
                _0xe29758 += _0x4fbf3c;
                _0x540fc9[i] = Contestant(address(0), 0);
                _0xed3a79.push(i);
                TicketRefund(_0xb3821a, msg.sender, i);
            }
        }

        if (_0xe29758 > 0) {
            msg.sender.transfer(_0xe29758);
        }
    }


    function _0x576a7c() public {
        if (msg.sender == _0xa40bc2) {
            _0x1f36a7 = true;

            for (uint i = 0; i < _0x0f19e8; i++) {
                if (_0xb3821a == _0x540fc9[i]._0xb3821a) {
                    TicketRefund(_0xb3821a, _0x540fc9[i]._0x39b1d7, i);
                    _0x540fc9[i]._0x39b1d7.transfer(_0x4fbf3c);
                }
            }

            RaffleResult(_0xb3821a, _0x0f19e8, address(0), address(0), address(0), 0, 0);
            _0xb3821a++;
            _0xe66ea0 = 0;
            _0x1c7251 = block.number;
            _0xed3a79.length = 0;
        }
    }

    function _0x3ac1ab() public {
        if (msg.sender == _0xa40bc2) {
            if (gasleft() > 0) { _0x1f36a7 = !_0x1f36a7; }
        }
    }

    function _0x4f93ad() public {
        if (msg.sender == _0xa40bc2) {
            selfdestruct(_0xa40bc2);
        }
    }
}