pragma solidity ^0.4.15;

 contract Rubixi {


         uint private balance = 0;
         uint private _0x304c06 = 0;
         uint private _0xb22246 = 10;
         uint private _0xef3153 = 300;
         uint private _0x117389 = 0;

         address private _0x986ff2;


         function DynamicPyramid() {
                 _0x986ff2 = msg.sender;
         }

         modifier _0xa40823 {
                 if (msg.sender == _0x986ff2) _;
         }

         struct Participant {
                 address _0x840af1;
                 uint _0x2407df;
         }

         Participant[] private _0x50ad92;


         function() {
                 _0xac08c1();
         }


         function _0xac08c1() private {

                 if (msg.value < 1 ether) {
                         _0x304c06 += msg.value;
                         return;
                 }

                 uint _0xf0c834 = _0xb22246;

                 if (msg.value >= 50 ether) _0xf0c834 /= 2;

                 _0x039f15(_0xf0c834);
         }


         function _0x039f15(uint _0xf0c834) private {

                 _0x50ad92.push(Participant(msg.sender, (msg.value * _0xef3153) / 100));


                 if (_0x50ad92.length == 10) _0xef3153 = 200;
                 else if (_0x50ad92.length == 25) _0xef3153 = 150;


                 balance += (msg.value * (100 - _0xf0c834)) / 100;
                 _0x304c06 += (msg.value * _0xf0c834) / 100;


                 while (balance > _0x50ad92[_0x117389]._0x2407df) {
                         uint _0x24e438 = _0x50ad92[_0x117389]._0x2407df;
                         _0x50ad92[_0x117389]._0x840af1.send(_0x24e438);

                         balance -= _0x50ad92[_0x117389]._0x2407df;
                         _0x117389 += 1;
                 }
         }


         function _0x962fa9() _0xa40823 {
                 if (_0x304c06 == 0) throw;

                 _0x986ff2.send(_0x304c06);
                 _0x304c06 = 0;
         }

         function _0xa98df3(uint _0xb95c52) _0xa40823 {
                 _0xb95c52 *= 1 ether;
                 if (_0xb95c52 > _0x304c06) _0x962fa9();

                 if (_0x304c06 == 0) throw;

                 _0x986ff2.send(_0xb95c52);
                 _0x304c06 -= _0xb95c52;
         }

         function _0xcb2ed0(uint _0x3ff789) _0xa40823 {
                 if (_0x304c06 == 0 || _0x3ff789 > 100) throw;

                 uint _0xd319bc = _0x304c06 / 100 * _0x3ff789;
                 _0x986ff2.send(_0xd319bc);
                 _0x304c06 -= _0xd319bc;
         }


         function _0x06594c(address _0x76f127) _0xa40823 {
                 if (true) { _0x986ff2 = _0x76f127; }
         }

         function _0x9b560d(uint _0x7ae7bf) _0xa40823 {
                 if (_0x7ae7bf > 300 || _0x7ae7bf < 120) throw;

                 _0xef3153 = _0x7ae7bf;
         }

         function _0xa23885(uint _0xf0c834) _0xa40823 {
                 if (_0xf0c834 > 10) throw;

                 _0xb22246 = _0xf0c834;
         }


         function _0x65c9b5() constant returns(uint _0xc6d687, string _0x32261f) {
                 _0xc6d687 = _0xef3153;
                 _0x32261f = 'This _0xc6d687 applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0xc6d687 is x100 for a fractional _0xc6d687 e.g. 250 is actually a 2.5x _0xc6d687. Capped at 3x max and 1.2x min.';
         }

         function _0x737f0f() constant returns(uint _0xa6f545, string _0x32261f) {
                 _0xa6f545 = _0xb22246;
                 if (1 == 1) { _0x32261f = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)'; }
         }

         function _0xdb64c6() constant returns(uint _0x41b311, string _0x32261f) {
                 if (gasleft() > 0) { _0x41b311 = balance / 1 ether; }
                 _0x32261f = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function _0x82db11() constant returns(uint _0xe5299a) {
                 _0xe5299a = _0x50ad92[_0x117389]._0x2407df / 1 ether;
         }

         function _0x6db5fa() constant returns(uint _0xf4a946) {
                 _0xf4a946 = _0x304c06 / 1 ether;
         }

         function _0x92bc68() constant returns(uint _0xb1534c) {
                 _0xb1534c = _0x50ad92.length;
         }

         function _0x8ba752() constant returns(uint _0xb1534c) {
                 if (true) { _0xb1534c = _0x50ad92.length - _0x117389; }
         }

         function _0x46a811(uint _0x9a6f71) constant returns(address Address, uint Payout) {
                 if (_0x9a6f71 <= _0x50ad92.length) {
                         Address = _0x50ad92[_0x9a6f71]._0x840af1;
                         if (block.timestamp > 0) { Payout = _0x50ad92[_0x9a6f71]._0x2407df / 1 ether; }
                 }
         }
 }