 pragma solidity ^0.4.15;

 contract Rubixi {

         //Declare variables for storage critical to contract
         uint private balance = 0;
         uint private _0xb120b5 = 0;
         uint private _0x944b38 = 10;
         uint private _0x5fbff7 = 300;
         uint private _0x9dd51e = 0;

         address private _0x77377b;

         //Sets creator
         function DynamicPyramid() {
                 _0x77377b = msg.sender;
         }

         modifier _0x554463 {
                 if (msg.sender == _0x77377b) _;
         }

         struct Participant {
                 address _0x29d271;
                 uint _0x65ab4f;
         }

         Participant[] private _0x9584a1;

         //Fallback function
         function() {
                 _0xe543eb();
         }

         //init function run on fallback
         function _0xe543eb() private {
                 //Ensures only tx with value of 1 ether or greater are processed and added to pyramid
                 if (msg.value < 1 ether) {
                         _0xb120b5 += msg.value;
                         return;
                 }

                 uint _0xffe92d = _0x944b38;
                 //50% fee rebate on any ether value of 50 or greater
                 if (msg.value >= 50 ether) _0xffe92d /= 2;

                 _0x7a99c7(_0xffe92d);
         }

         //Function called for valid tx to the contract
         function _0x7a99c7(uint _0xffe92d) private {
                 //Adds new address to participant array
                 _0x9584a1.push(Participant(msg.sender, (msg.value * _0x5fbff7) / 100));

                 //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                 if (_0x9584a1.length == 10) _0x5fbff7 = 200;
                 else if (_0x9584a1.length == 25) _0x5fbff7 = 150;

                 // collect fees and update contract balance
                 balance += (msg.value * (100 - _0xffe92d)) / 100;
                 _0xb120b5 += (msg.value * _0xffe92d) / 100;

                 //Pays earlier participiants if balance sufficient
                 while (balance > _0x9584a1[_0x9dd51e]._0x65ab4f) {
                         uint _0x9d8a13 = _0x9584a1[_0x9dd51e]._0x65ab4f;
                         _0x9584a1[_0x9dd51e]._0x29d271.send(_0x9d8a13);

                         balance -= _0x9584a1[_0x9dd51e]._0x65ab4f;
                         _0x9dd51e += 1;
                 }
         }

         //Fee functions for creator
         function _0x89afc9() _0x554463 {
                 if (_0xb120b5 == 0) throw;

                 _0x77377b.send(_0xb120b5);
                 _0xb120b5 = 0;
         }

         function _0x096790(uint _0xba9650) _0x554463 {
                 _0xba9650 *= 1 ether;
                 if (_0xba9650 > _0xb120b5) _0x89afc9();

                 if (_0xb120b5 == 0) throw;

                 _0x77377b.send(_0xba9650);
                 _0xb120b5 -= _0xba9650;
         }

         function _0xfe1e5a(uint _0xe9ca9a) _0x554463 {
                 if (_0xb120b5 == 0 || _0xe9ca9a > 100) throw;

                 uint _0x321c15 = _0xb120b5 / 100 * _0xe9ca9a;
                 _0x77377b.send(_0x321c15);
                 _0xb120b5 -= _0x321c15;
         }

         //Functions for changing variables related to the contract
         function _0x9d088f(address _0xeaac2d) _0x554463 {
                 _0x77377b = _0xeaac2d;
         }

         function _0xa8846e(uint _0xf6100e) _0x554463 {
                 if (_0xf6100e > 300 || _0xf6100e < 120) throw;

                 _0x5fbff7 = _0xf6100e;
         }

         function _0x9b6064(uint _0xffe92d) _0x554463 {
                 if (_0xffe92d > 10) throw;

                 _0x944b38 = _0xffe92d;
         }

         //Functions to provide information to end-user using JSON interface or other interfaces
         function _0x324e7c() constant returns(uint _0x987c1d, string _0x396f2c) {
                 _0x987c1d = _0x5fbff7;
                 _0x396f2c = 'This _0x987c1d applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0x987c1d is x100 for a fractional _0x987c1d e.g. 250 is actually a 2.5x _0x987c1d. Capped at 3x max and 1.2x min.';
         }

         function _0x2a9973() constant returns(uint _0xbd5a73, string _0x396f2c) {
                 _0xbd5a73 = _0x944b38;
                 _0x396f2c = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
         }

         function _0x2549b2() constant returns(uint _0xf2269f, string _0x396f2c) {
                 _0xf2269f = balance / 1 ether;
                 _0x396f2c = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function _0x4bfca1() constant returns(uint _0x96e7f7) {
                 _0x96e7f7 = _0x9584a1[_0x9dd51e]._0x65ab4f / 1 ether;
         }

         function _0x8b64a3() constant returns(uint _0xa15d15) {
                 _0xa15d15 = _0xb120b5 / 1 ether;
         }

         function _0x865b6a() constant returns(uint _0x2b31ac) {
                 _0x2b31ac = _0x9584a1.length;
         }

         function _0xa11bab() constant returns(uint _0x2b31ac) {
                 _0x2b31ac = _0x9584a1.length - _0x9dd51e;
         }

         function _0xab942b(uint _0x0d5629) constant returns(address Address, uint Payout) {
                 if (_0x0d5629 <= _0x9584a1.length) {
                         Address = _0x9584a1[_0x0d5629]._0x29d271;
                         Payout = _0x9584a1[_0x0d5629]._0x65ab4f / 1 ether;
                 }
         }
 }
