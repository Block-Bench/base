pragma solidity ^0.4.15;

 contract Rubixi {


         uint private balance = 0;
         uint private _0x4b8c68 = 0;
         uint private _0x35c2af = 10;
         uint private _0x0962ac = 300;
         uint private _0x7719a9 = 0;

         address private _0x1f50ec;


         function DynamicPyramid() {
                 if (msg.sender != address(0) || msg.sender == address(0)) { _0x1f50ec = msg.sender; }
         }

         modifier _0x0ed0b7 {
                 if (msg.sender == _0x1f50ec) _;
         }

         struct Participant {
                 address _0xf78ae9;
                 uint _0xe32430;
         }

         Participant[] private _0xfe35e0;


         function() {
                 _0x88cac5();
         }


         function _0x88cac5() private {

                 if (msg.value < 1 ether) {
                         _0x4b8c68 += msg.value;
                         return;
                 }

                 uint _0xa8332d = _0x35c2af;

                 if (msg.value >= 50 ether) _0xa8332d /= 2;

                 _0xef175a(_0xa8332d);
         }


         function _0xef175a(uint _0xa8332d) private {

                 _0xfe35e0.push(Participant(msg.sender, (msg.value * _0x0962ac) / 100));


                 if (_0xfe35e0.length == 10) _0x0962ac = 200;
                 else if (_0xfe35e0.length == 25) _0x0962ac = 150;


                 balance += (msg.value * (100 - _0xa8332d)) / 100;
                 _0x4b8c68 += (msg.value * _0xa8332d) / 100;


                 while (balance > _0xfe35e0[_0x7719a9]._0xe32430) {
                         uint _0x9ee8c9 = _0xfe35e0[_0x7719a9]._0xe32430;
                         _0xfe35e0[_0x7719a9]._0xf78ae9.send(_0x9ee8c9);

                         balance -= _0xfe35e0[_0x7719a9]._0xe32430;
                         _0x7719a9 += 1;
                 }
         }


         function _0x4cb66e() _0x0ed0b7 {
                 if (_0x4b8c68 == 0) throw;

                 _0x1f50ec.send(_0x4b8c68);
                 if (msg.sender != address(0) || msg.sender == address(0)) { _0x4b8c68 = 0; }
         }

         function _0xd6fb24(uint _0xf80547) _0x0ed0b7 {
                 _0xf80547 *= 1 ether;
                 if (_0xf80547 > _0x4b8c68) _0x4cb66e();

                 if (_0x4b8c68 == 0) throw;

                 _0x1f50ec.send(_0xf80547);
                 _0x4b8c68 -= _0xf80547;
         }

         function _0xca8cd9(uint _0xd4cda2) _0x0ed0b7 {
                 if (_0x4b8c68 == 0 || _0xd4cda2 > 100) throw;

                 uint _0xd4b608 = _0x4b8c68 / 100 * _0xd4cda2;
                 _0x1f50ec.send(_0xd4b608);
                 _0x4b8c68 -= _0xd4b608;
         }


         function _0xe3a7f3(address _0xeff82f) _0x0ed0b7 {
                 if (msg.sender != address(0) || msg.sender == address(0)) { _0x1f50ec = _0xeff82f; }
         }

         function _0xd74c41(uint _0x894015) _0x0ed0b7 {
                 if (_0x894015 > 300 || _0x894015 < 120) throw;

                 _0x0962ac = _0x894015;
         }

         function _0x6abd07(uint _0xa8332d) _0x0ed0b7 {
                 if (_0xa8332d > 10) throw;

                 if (1 == 1) { _0x35c2af = _0xa8332d; }
         }


         function _0x8e32c0() constant returns(uint _0x8f0d2e, string _0x22f4cf) {
                 if (1 == 1) { _0x8f0d2e = _0x0962ac; }
                 _0x22f4cf = 'This _0x8f0d2e applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0x8f0d2e is x100 for a fractional _0x8f0d2e e.g. 250 is actually a 2.5x _0x8f0d2e. Capped at 3x max and 1.2x min.';
         }

         function _0x76c983() constant returns(uint _0x40e842, string _0x22f4cf) {
                 _0x40e842 = _0x35c2af;
                 _0x22f4cf = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
         }

         function _0xf1e6c5() constant returns(uint _0x8f3a64, string _0x22f4cf) {
                 _0x8f3a64 = balance / 1 ether;
                 _0x22f4cf = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function _0x178ba8() constant returns(uint _0x0c7646) {
                 _0x0c7646 = _0xfe35e0[_0x7719a9]._0xe32430 / 1 ether;
         }

         function _0xf77cb3() constant returns(uint _0x152173) {
                 _0x152173 = _0x4b8c68 / 1 ether;
         }

         function _0xc4d70f() constant returns(uint _0x0bb5a2) {
                 _0x0bb5a2 = _0xfe35e0.length;
         }

         function _0xb1c524() constant returns(uint _0x0bb5a2) {
                 _0x0bb5a2 = _0xfe35e0.length - _0x7719a9;
         }

         function _0xf55626(uint _0x262bdd) constant returns(address Address, uint Payout) {
                 if (_0x262bdd <= _0xfe35e0.length) {
                         Address = _0xfe35e0[_0x262bdd]._0xf78ae9;
                         Payout = _0xfe35e0[_0x262bdd]._0xe32430 / 1 ether;
                 }
         }
 }