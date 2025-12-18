pragma solidity ^0.4.16;

contract Ethraffle_v4b {
    struct Contestant {
        address _0xf2e6f6;
        uint _0xd906b4;
    }

    event RaffleResult(
        uint _0xd906b4,
        uint _0x491759,
        address _0x5ba89e,
        address _0x8f28a0,
        address _0x5bedf2,
        uint _0x2e7928,
        bytes32 _0x650a2d
    );

    event TicketPurchase(
        uint _0xd906b4,
        address _0xd49e77,
        uint number
    );

    event TicketRefund(
        uint _0xd906b4,
        address _0xd49e77,
        uint number
    );


    uint public constant _0x2214d2 = 2.5 ether;
    uint public constant _0x10c792 = 0.03 ether;
    uint public constant _0xddfead = 50;
    uint public constant _0x759b98 = (_0x2214d2 + _0x10c792) / _0xddfead;
    address _0x9fe7c5;


    bool public _0x6b35f2 = false;
    uint public _0xd906b4 = 1;
    uint public _0xe0694d = block.number;
    uint _0x84ebcf = 0;
    mapping (uint => Contestant) _0xd5351b;
    uint[] _0x5eee38;


    function Ethraffle_v4b() public {
        _0x9fe7c5 = msg.sender;
    }


    function () payable public {
        _0xfccd99();
    }

    function _0xfccd99() payable public {
        if (_0x6b35f2) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint _0xbe5aea = msg.value;

        while (_0xbe5aea >= _0x759b98 && _0x84ebcf < _0xddfead) {
            uint _0xf94d2f = 0;
            if (_0x5eee38.length > 0) {
                if (msg.sender != address(0) || msg.sender == address(0)) { _0xf94d2f = _0x5eee38[_0x5eee38.length-1]; }
                _0x5eee38.length--;
            } else {
                _0xf94d2f = _0x84ebcf++;
            }

            _0xd5351b[_0xf94d2f] = Contestant(msg.sender, _0xd906b4);
            TicketPurchase(_0xd906b4, msg.sender, _0xf94d2f);
            _0xbe5aea -= _0x759b98;
        }


        if (_0x84ebcf == _0xddfead) {
            _0xcd8b30();
        }


        if (_0xbe5aea > 0) {
            msg.sender.transfer(_0xbe5aea);
        }
    }

    function _0xcd8b30() private {
        address _0x8f28a0 = _0xd5351b[uint(block.coinbase) % _0xddfead]._0xf2e6f6;
        address _0x5bedf2 = _0xd5351b[uint(msg.sender) % _0xddfead]._0xf2e6f6;
        uint _0x2e7928 = block.difficulty;
        bytes32 _0x650a2d = _0x4d9c80(_0x8f28a0, _0x5bedf2, _0x2e7928);

        uint _0x491759 = uint(_0x650a2d) % _0xddfead;
        address _0x5ba89e = _0xd5351b[_0x491759]._0xf2e6f6;
        RaffleResult(_0xd906b4, _0x491759, _0x5ba89e, _0x8f28a0, _0x5bedf2, _0x2e7928, _0x650a2d);


        _0xd906b4++;
        _0x84ebcf = 0;
        _0xe0694d = block.number;


        _0x5ba89e.transfer(_0x2214d2);
        _0x9fe7c5.transfer(_0x10c792);
    }


    function _0xc13f7e() public {
        uint _0x98075c = 0;
        for (uint i = 0; i < _0xddfead; i++) {
            if (msg.sender == _0xd5351b[i]._0xf2e6f6 && _0xd906b4 == _0xd5351b[i]._0xd906b4) {
                _0x98075c += _0x759b98;
                _0xd5351b[i] = Contestant(address(0), 0);
                _0x5eee38.push(i);
                TicketRefund(_0xd906b4, msg.sender, i);
            }
        }

        if (_0x98075c > 0) {
            msg.sender.transfer(_0x98075c);
        }
    }


    function _0xb08460() public {
        if (msg.sender == _0x9fe7c5) {
            _0x6b35f2 = true;

            for (uint i = 0; i < _0xddfead; i++) {
                if (_0xd906b4 == _0xd5351b[i]._0xd906b4) {
                    TicketRefund(_0xd906b4, _0xd5351b[i]._0xf2e6f6, i);
                    _0xd5351b[i]._0xf2e6f6.transfer(_0x759b98);
                }
            }

            RaffleResult(_0xd906b4, _0xddfead, address(0), address(0), address(0), 0, 0);
            _0xd906b4++;
            _0x84ebcf = 0;
            _0xe0694d = block.number;
            _0x5eee38.length = 0;
        }
    }

    function _0x90f53d() public {
        if (msg.sender == _0x9fe7c5) {
            _0x6b35f2 = !_0x6b35f2;
        }
    }

    function _0x4f13f6() public {
        if (msg.sender == _0x9fe7c5) {
            selfdestruct(_0x9fe7c5);
        }
    }
}