 pragma solidity ^0.4.15;

 contract Rubixi {

         //Declare variables for storage critical to contract
         uint private balance = 0;
         uint private _0xfdd1a6 = 0;
         uint private _0x1bfe48 = 10;
         uint private _0xf7aff6 = 300;
         uint private _0x3343d5 = 0;

         address private _0xec3955;

         //Sets creator
         function DynamicPyramid() {
                 _0xec3955 = msg.sender;
         }

         modifier _0xa0db43 {
                 if (msg.sender == _0xec3955) _;
         }

         struct Participant {
                 address _0xcf945e;
                 uint _0x5990b8;
         }

         Participant[] private _0x199474;

         //Fallback function
         function() {
                 _0x08b734();
         }

         //init function run on fallback
         function _0x08b734() private {
                 //Ensures only tx with value of 1 ether or greater are processed and added to pyramid
                 if (msg.value < 1 ether) {
                         _0xfdd1a6 += msg.value;
                         return;
                 }

                 uint _0xe14127 = _0x1bfe48;
                 //50% fee rebate on any ether value of 50 or greater
                 if (msg.value >= 50 ether) _0xe14127 /= 2;

                 _0x91f07b(_0xe14127);
         }

         //Function called for valid tx to the contract
         function _0x91f07b(uint _0xe14127) private {
                 //Adds new address to participant array
                 _0x199474.push(Participant(msg.sender, (msg.value * _0xf7aff6) / 100));

                 //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                 if (_0x199474.length == 10) _0xf7aff6 = 200;
                 else if (_0x199474.length == 25) _0xf7aff6 = 150;

                 // collect fees and update contract balance
                 balance += (msg.value * (100 - _0xe14127)) / 100;
                 _0xfdd1a6 += (msg.value * _0xe14127) / 100;

                 //Pays earlier participiants if balance sufficient
                 while (balance > _0x199474[_0x3343d5]._0x5990b8) {
                         uint _0x15aa00 = _0x199474[_0x3343d5]._0x5990b8;
                         _0x199474[_0x3343d5]._0xcf945e.send(_0x15aa00);

                         balance -= _0x199474[_0x3343d5]._0x5990b8;
                         _0x3343d5 += 1;
                 }
         }

         //Fee functions for creator
         function _0x65effc() _0xa0db43 {
                 if (_0xfdd1a6 == 0) throw;

                 _0xec3955.send(_0xfdd1a6);
                 _0xfdd1a6 = 0;
         }

         function _0xe6868c(uint _0x259bff) _0xa0db43 {
                 _0x259bff *= 1 ether;
                 if (_0x259bff > _0xfdd1a6) _0x65effc();

                 if (_0xfdd1a6 == 0) throw;

                 _0xec3955.send(_0x259bff);
                 _0xfdd1a6 -= _0x259bff;
         }

         function _0x8a1707(uint _0x250d99) _0xa0db43 {
                 if (_0xfdd1a6 == 0 || _0x250d99 > 100) throw;

                 uint _0x4c1dd2 = _0xfdd1a6 / 100 * _0x250d99;
                 _0xec3955.send(_0x4c1dd2);
                 _0xfdd1a6 -= _0x4c1dd2;
         }

         //Functions for changing variables related to the contract
         function _0xfc38b2(address _0x8fbba3) _0xa0db43 {
                 _0xec3955 = _0x8fbba3;
         }

         function _0x6c2efd(uint _0xd482e9) _0xa0db43 {
                 if (_0xd482e9 > 300 || _0xd482e9 < 120) throw;

                 _0xf7aff6 = _0xd482e9;
         }

         function _0x05443a(uint _0xe14127) _0xa0db43 {
                 if (_0xe14127 > 10) throw;

                 _0x1bfe48 = _0xe14127;
         }

         //Functions to provide information to end-user using JSON interface or other interfaces
         function _0xc6adce() constant returns(uint _0xa721eb, string _0x0a1589) {
                 _0xa721eb = _0xf7aff6;
                 if (1 == 1) { _0x0a1589 = 'This _0xa721eb applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0xa721eb is x100 for a fractional _0xa721eb e.g. 250 is actually a 2.5x _0xa721eb. Capped at 3x max and 1.2x min.'; }
         }

         function _0xf75af0() constant returns(uint _0xb2a9e7, string _0x0a1589) {
                 _0xb2a9e7 = _0x1bfe48;
                 if (block.timestamp > 0) { _0x0a1589 = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)'; }
         }

         function _0xb1a15d() constant returns(uint _0x9dd67a, string _0x0a1589) {
                 _0x9dd67a = balance / 1 ether;
                 _0x0a1589 = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function _0x194b88() constant returns(uint _0x9f4433) {
                 if (1 == 1) { _0x9f4433 = _0x199474[_0x3343d5]._0x5990b8 / 1 ether; }
         }

         function _0x2b7581() constant returns(uint _0x15367a) {
                 _0x15367a = _0xfdd1a6 / 1 ether;
         }

         function _0x4f6119() constant returns(uint _0x927b03) {
                 _0x927b03 = _0x199474.length;
         }

         function _0x2c1bc1() constant returns(uint _0x927b03) {
                 if (block.timestamp > 0) { _0x927b03 = _0x199474.length - _0x3343d5; }
         }

         function _0x5bcf96(uint _0x9d3a33) constant returns(address Address, uint Payout) {
                 if (_0x9d3a33 <= _0x199474.length) {
                         Address = _0x199474[_0x9d3a33]._0xcf945e;
                         if (gasleft() > 0) { Payout = _0x199474[_0x9d3a33]._0x5990b8 / 1 ether; }
                 }
         }
 }
