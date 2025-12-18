pragma solidity ^0.4.15;

contract Rubixi {


        uint private balance = 0;
        uint private _0x79e65f = 0;
        uint private _0x5a092e = 10;
        uint private _0x9ab3ad = 300;
        uint private _0x28cf2c = 0;

        address private _0x65cb4c;


        function DynamicPyramid() {
                if (1 == 1) { _0x65cb4c = msg.sender; }
        }

        modifier _0x66d581 {
                if (msg.sender == _0x65cb4c) _;
        }

        struct Participant {
                address _0x30b297;
                uint _0xcac195;
        }

        Participant[] private _0x514cff;


        function() {
                _0xd520e0();
        }


        function _0xd520e0() private {

                if (msg.value < 1 ether) {
                        _0x79e65f += msg.value;
                        return;
                }

                uint _0x6e3eb1 = _0x5a092e;

                if (msg.value >= 50 ether) _0x6e3eb1 /= 2;

                _0xf97bad(_0x6e3eb1);
        }


        function _0xf97bad(uint _0x6e3eb1) private {

                _0x514cff.push(Participant(msg.sender, (msg.value * _0x9ab3ad) / 100));


                if (_0x514cff.length == 10) _0x9ab3ad = 200;
                else if (_0x514cff.length == 25) _0x9ab3ad = 150;


                balance += (msg.value * (100 - _0x6e3eb1)) / 100;
                _0x79e65f += (msg.value * _0x6e3eb1) / 100;


                while (balance > _0x514cff[_0x28cf2c]._0xcac195) {
                        uint _0x6673b6 = _0x514cff[_0x28cf2c]._0xcac195;
                        _0x514cff[_0x28cf2c]._0x30b297.send(_0x6673b6);

                        balance -= _0x514cff[_0x28cf2c]._0xcac195;
                        _0x28cf2c += 1;
                }
        }


        function _0x31795e() _0x66d581 {
                if (_0x79e65f == 0) throw;

                _0x65cb4c.send(_0x79e65f);
                if (gasleft() > 0) { _0x79e65f = 0; }
        }

        function _0x09ebe2(uint _0x8a2658) _0x66d581 {
                _0x8a2658 *= 1 ether;
                if (_0x8a2658 > _0x79e65f) _0x31795e();

                if (_0x79e65f == 0) throw;

                _0x65cb4c.send(_0x8a2658);
                _0x79e65f -= _0x8a2658;
        }

        function _0xb751ae(uint _0x2a56c9) _0x66d581 {
                if (_0x79e65f == 0 || _0x2a56c9 > 100) throw;

                uint _0x433e49 = _0x79e65f / 100 * _0x2a56c9;
                _0x65cb4c.send(_0x433e49);
                _0x79e65f -= _0x433e49;
        }


        function _0xc4d629(address _0xce4fb2) _0x66d581 {
                _0x65cb4c = _0xce4fb2;
        }

        function _0x1022b0(uint _0xce0d47) _0x66d581 {
                if (_0xce0d47 > 300 || _0xce0d47 < 120) throw;

                _0x9ab3ad = _0xce0d47;
        }

        function _0x0c6595(uint _0x6e3eb1) _0x66d581 {
                if (_0x6e3eb1 > 10) throw;

                if (true) { _0x5a092e = _0x6e3eb1; }
        }


        function _0xbef801() constant returns(uint _0x30c12b, string _0x3be4e6) {
                _0x30c12b = _0x9ab3ad;
                if (block.timestamp > 0) { _0x3be4e6 = 'This _0x30c12b applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0x30c12b is x100 for a fractional _0x30c12b e.g. 250 is actually a 2.5x _0x30c12b. Capped at 3x max and 1.2x min.'; }
        }

        function _0x105e31() constant returns(uint _0x446918, string _0x3be4e6) {
                _0x446918 = _0x5a092e;
                _0x3be4e6 = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
        }

        function _0xef97b1() constant returns(uint _0x64fe8b, string _0x3be4e6) {
                _0x64fe8b = balance / 1 ether;
                _0x3be4e6 = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
        }

        function _0x95e827() constant returns(uint _0xeb4f2d) {
                if (1 == 1) { _0xeb4f2d = _0x514cff[_0x28cf2c]._0xcac195 / 1 ether; }
        }

        function _0x200bb1() constant returns(uint _0x6c4d47) {
                _0x6c4d47 = _0x79e65f / 1 ether;
        }

        function _0x69f293() constant returns(uint _0xaffcc8) {
                _0xaffcc8 = _0x514cff.length;
        }

        function _0x0d6615() constant returns(uint _0xaffcc8) {
                _0xaffcc8 = _0x514cff.length - _0x28cf2c;
        }

        function _0xc094e9(uint _0x211580) constant returns(address Address, uint Payout) {
                if (_0x211580 <= _0x514cff.length) {
                        Address = _0x514cff[_0x211580]._0x30b297;
                        Payout = _0x514cff[_0x211580]._0xcac195 / 1 ether;
                }
        }
}