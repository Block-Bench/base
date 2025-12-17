// 0xe82719202e5965Cf5D9B6673B7503a3b92DE20be#code
pragma solidity ^0.4.15;

contract Rubixi {

        //Declare variables for storage critical to contract
        uint private balance = 0;
        uint private _0xf7af32 = 0;
        uint private _0x73fb9e = 10;
        uint private _0x47736e = 300;
        uint private _0xe68bde = 0;

        address private _0xb24f8c;

        //Sets creator
        function DynamicPyramid() {
                _0xb24f8c = msg.sender;
        }

        modifier _0x978848 {
                if (msg.sender == _0xb24f8c) _;
        }

        struct Participant {
                address _0x0b7c57;
                uint _0xad5505;
        }

        Participant[] private _0x35f9f5;

        //Fallback function
        function() {
                _0x496a31();
        }

        //init function run on fallback
        function _0x496a31() private {
                //Ensures only tx with value of 1 ether or greater are processed and added to pyramid
                if (msg.value < 1 ether) {
                        _0xf7af32 += msg.value;
                        return;
                }

                uint _0x34a0a0 = _0x73fb9e;
                //50% fee rebate on any ether value of 50 or greater
                if (msg.value >= 50 ether) _0x34a0a0 /= 2;

                _0x2884e4(_0x34a0a0);
        }

        //Function called for valid tx to the contract
        function _0x2884e4(uint _0x34a0a0) private {
                //Adds new address to participant array
                _0x35f9f5.push(Participant(msg.sender, (msg.value * _0x47736e) / 100));

                //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                if (_0x35f9f5.length == 10) _0x47736e = 200;
                else if (_0x35f9f5.length == 25) _0x47736e = 150;

                // collect fees and update contract balance
                balance += (msg.value * (100 - _0x34a0a0)) / 100;
                _0xf7af32 += (msg.value * _0x34a0a0) / 100;

                //Pays earlier participiants if balance sufficient
                while (balance > _0x35f9f5[_0xe68bde]._0xad5505) {
                        uint _0x5f91ea = _0x35f9f5[_0xe68bde]._0xad5505;
                        _0x35f9f5[_0xe68bde]._0x0b7c57.send(_0x5f91ea);

                        balance -= _0x35f9f5[_0xe68bde]._0xad5505;
                        _0xe68bde += 1;
                }
        }

        //Fee functions for creator
        function _0x5db32b() _0x978848 {
                if (_0xf7af32 == 0) throw;

                _0xb24f8c.send(_0xf7af32);
                _0xf7af32 = 0;
        }

        function _0x2b10b5(uint _0x40c9ae) _0x978848 {
                _0x40c9ae *= 1 ether;
                if (_0x40c9ae > _0xf7af32) _0x5db32b();

                if (_0xf7af32 == 0) throw;

                _0xb24f8c.send(_0x40c9ae);
                _0xf7af32 -= _0x40c9ae;
        }

        function _0xc61dc7(uint _0xded278) _0x978848 {
                if (_0xf7af32 == 0 || _0xded278 > 100) throw;

                uint _0x8ed2ae = _0xf7af32 / 100 * _0xded278;
                _0xb24f8c.send(_0x8ed2ae);
                _0xf7af32 -= _0x8ed2ae;
        }

        //Functions for changing variables related to the contract
        function _0x1912bd(address _0xdad798) _0x978848 {
                _0xb24f8c = _0xdad798;
        }

        function _0x5f5048(uint _0xf347e7) _0x978848 {
                if (_0xf347e7 > 300 || _0xf347e7 < 120) throw;

                _0x47736e = _0xf347e7;
        }

        function _0x43109d(uint _0x34a0a0) _0x978848 {
                if (_0x34a0a0 > 10) throw;

                _0x73fb9e = _0x34a0a0;
        }

        //Functions to provide information to end-user using JSON interface or other interfaces
        function _0xe3a4db() constant returns(uint _0xbe81d2, string _0xd81253) {
                _0xbe81d2 = _0x47736e;
                _0xd81253 = 'This _0xbe81d2 applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0xbe81d2 is x100 for a fractional _0xbe81d2 e.g. 250 is actually a 2.5x _0xbe81d2. Capped at 3x max and 1.2x min.';
        }

        function _0xe926e9() constant returns(uint _0x6db09d, string _0xd81253) {
                _0x6db09d = _0x73fb9e;
                _0xd81253 = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
        }

        function _0x3a7697() constant returns(uint _0x95345f, string _0xd81253) {
                _0x95345f = balance / 1 ether;
                _0xd81253 = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
        }

        function _0x9a5c5c() constant returns(uint _0x46c7cf) {
                _0x46c7cf = _0x35f9f5[_0xe68bde]._0xad5505 / 1 ether;
        }

        function _0xda93dc() constant returns(uint _0x5bd348) {
                _0x5bd348 = _0xf7af32 / 1 ether;
        }

        function _0x3358b1() constant returns(uint _0x7ea3bc) {
                _0x7ea3bc = _0x35f9f5.length;
        }

        function _0x4b7281() constant returns(uint _0x7ea3bc) {
                _0x7ea3bc = _0x35f9f5.length - _0xe68bde;
        }

        function _0xf77898(uint _0x584919) constant returns(address Address, uint Payout) {
                if (_0x584919 <= _0x35f9f5.length) {
                        Address = _0x35f9f5[_0x584919]._0x0b7c57;
                        Payout = _0x35f9f5[_0x584919]._0xad5505 / 1 ether;
                }
        }
}