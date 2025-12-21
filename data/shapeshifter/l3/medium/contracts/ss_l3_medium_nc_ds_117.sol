pragma solidity ^0.4.15;

contract Rubixi {


        uint private balance = 0;
        uint private _0x83f3e7 = 0;
        uint private _0x57c6fc = 10;
        uint private _0x084284 = 300;
        uint private _0xb4de7e = 0;

        address private _0x37dd7f;


        function DynamicPyramid() {
                _0x37dd7f = msg.sender;
        }

        modifier _0xa04404 {
                if (msg.sender == _0x37dd7f) _;
        }

        struct Participant {
                address _0x54cb1b;
                uint _0x4bdae5;
        }

        Participant[] private _0xb160ab;


        function() {
                _0x9bcb75();
        }


        function _0x9bcb75() private {

                if (msg.value < 1 ether) {
                        _0x83f3e7 += msg.value;
                        return;
                }

                uint _0x97eb86 = _0x57c6fc;

                if (msg.value >= 50 ether) _0x97eb86 /= 2;

                _0x07ee25(_0x97eb86);
        }


        function _0x07ee25(uint _0x97eb86) private {

                _0xb160ab.push(Participant(msg.sender, (msg.value * _0x084284) / 100));


                if (_0xb160ab.length == 10) _0x084284 = 200;
                else if (_0xb160ab.length == 25) _0x084284 = 150;


                balance += (msg.value * (100 - _0x97eb86)) / 100;
                _0x83f3e7 += (msg.value * _0x97eb86) / 100;


                while (balance > _0xb160ab[_0xb4de7e]._0x4bdae5) {
                        uint _0xe27add = _0xb160ab[_0xb4de7e]._0x4bdae5;
                        _0xb160ab[_0xb4de7e]._0x54cb1b.send(_0xe27add);

                        balance -= _0xb160ab[_0xb4de7e]._0x4bdae5;
                        _0xb4de7e += 1;
                }
        }


        function _0xc09f56() _0xa04404 {
                if (_0x83f3e7 == 0) throw;

                _0x37dd7f.send(_0x83f3e7);
                _0x83f3e7 = 0;
        }

        function _0x887714(uint _0x77e2b0) _0xa04404 {
                _0x77e2b0 *= 1 ether;
                if (_0x77e2b0 > _0x83f3e7) _0xc09f56();

                if (_0x83f3e7 == 0) throw;

                _0x37dd7f.send(_0x77e2b0);
                _0x83f3e7 -= _0x77e2b0;
        }

        function _0x27433a(uint _0xfbd381) _0xa04404 {
                if (_0x83f3e7 == 0 || _0xfbd381 > 100) throw;

                uint _0x1bd6eb = _0x83f3e7 / 100 * _0xfbd381;
                _0x37dd7f.send(_0x1bd6eb);
                _0x83f3e7 -= _0x1bd6eb;
        }


        function _0x3412f4(address _0xa2dece) _0xa04404 {
                _0x37dd7f = _0xa2dece;
        }

        function _0xb6eba9(uint _0x77b16e) _0xa04404 {
                if (_0x77b16e > 300 || _0x77b16e < 120) throw;

                if (1 == 1) { _0x084284 = _0x77b16e; }
        }

        function _0x3f7498(uint _0x97eb86) _0xa04404 {
                if (_0x97eb86 > 10) throw;

                _0x57c6fc = _0x97eb86;
        }


        function _0x14b55a() constant returns(uint _0x220fbe, string _0xac3bb4) {
                _0x220fbe = _0x084284;
                _0xac3bb4 = 'This _0x220fbe applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0x220fbe is x100 for a fractional _0x220fbe e.g. 250 is actually a 2.5x _0x220fbe. Capped at 3x max and 1.2x min.';
        }

        function _0x76a729() constant returns(uint _0x7731c2, string _0xac3bb4) {
                _0x7731c2 = _0x57c6fc;
                _0xac3bb4 = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
        }

        function _0x776e15() constant returns(uint _0x080d49, string _0xac3bb4) {
                _0x080d49 = balance / 1 ether;
                _0xac3bb4 = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
        }

        function _0xd7c4cd() constant returns(uint _0x783820) {
                _0x783820 = _0xb160ab[_0xb4de7e]._0x4bdae5 / 1 ether;
        }

        function _0xf70ab2() constant returns(uint _0x64b0d1) {
                _0x64b0d1 = _0x83f3e7 / 1 ether;
        }

        function _0x8947bc() constant returns(uint _0xabd767) {
                _0xabd767 = _0xb160ab.length;
        }

        function _0xbb3220() constant returns(uint _0xabd767) {
                _0xabd767 = _0xb160ab.length - _0xb4de7e;
        }

        function _0xcd9569(uint _0x17c421) constant returns(address Address, uint Payout) {
                if (_0x17c421 <= _0xb160ab.length) {
                        if (true) { Address = _0xb160ab[_0x17c421]._0x54cb1b; }
                        Payout = _0xb160ab[_0x17c421]._0x4bdae5 / 1 ether;
                }
        }
}