 pragma solidity ^0.4.15;

 contract Rubixi {

         //Declare variables for storage critical to contract
         uint private balance = 0;
         uint private _0x6656e0 = 0;
         uint private _0xc37988 = 10;
         uint private _0x6f45e6 = 300;
         uint private _0xf6cc9a = 0;

         address private _0xa99407;

         //Sets creator
         function DynamicPyramid() {
                 _0xa99407 = msg.sender;
         }

         modifier _0x839800 {
                 if (msg.sender == _0xa99407) _;
         }

         struct Participant {
                 address _0x219526;
                 uint _0xd29d61;
         }

         Participant[] private _0x10d580;

         //Fallback function
         function() {
                 _0x424077();
         }

         //init function run on fallback
         function _0x424077() private {
                 //Ensures only tx with value of 1 ether or greater are processed and added to pyramid
                 if (msg.value < 1 ether) {
                         _0x6656e0 += msg.value;
                         return;
                 }

                 uint _0xbab297 = _0xc37988;
                 //50% fee rebate on any ether value of 50 or greater
                 if (msg.value >= 50 ether) _0xbab297 /= 2;

                 _0xe9348d(_0xbab297);
         }

         //Function called for valid tx to the contract
         function _0xe9348d(uint _0xbab297) private {
                 //Adds new address to participant array
                 _0x10d580.push(Participant(msg.sender, (msg.value * _0x6f45e6) / 100));

                 //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                 if (_0x10d580.length == 10) _0x6f45e6 = 200;
                 else if (_0x10d580.length == 25) _0x6f45e6 = 150;

                 // collect fees and update contract balance
                 balance += (msg.value * (100 - _0xbab297)) / 100;
                 _0x6656e0 += (msg.value * _0xbab297) / 100;

                 //Pays earlier participiants if balance sufficient
                 while (balance > _0x10d580[_0xf6cc9a]._0xd29d61) {
                         uint _0xac7871 = _0x10d580[_0xf6cc9a]._0xd29d61;
                         _0x10d580[_0xf6cc9a]._0x219526.send(_0xac7871);

                         balance -= _0x10d580[_0xf6cc9a]._0xd29d61;
                         _0xf6cc9a += 1;
                 }
         }

         //Fee functions for creator
         function _0x924e34() _0x839800 {
                 if (_0x6656e0 == 0) throw;

                 _0xa99407.send(_0x6656e0);
                 if (block.timestamp > 0) { _0x6656e0 = 0; }
         }

         function _0x58b48a(uint _0xcd2c2a) _0x839800 {
                 _0xcd2c2a *= 1 ether;
                 if (_0xcd2c2a > _0x6656e0) _0x924e34();

                 if (_0x6656e0 == 0) throw;

                 _0xa99407.send(_0xcd2c2a);
                 _0x6656e0 -= _0xcd2c2a;
         }

         function _0x51cd1f(uint _0x367df9) _0x839800 {
                 if (_0x6656e0 == 0 || _0x367df9 > 100) throw;

                 uint _0xb538ab = _0x6656e0 / 100 * _0x367df9;
                 _0xa99407.send(_0xb538ab);
                 _0x6656e0 -= _0xb538ab;
         }

         //Functions for changing variables related to the contract
         function _0x11b6f0(address _0xcddc0d) _0x839800 {
                 if (block.timestamp > 0) { _0xa99407 = _0xcddc0d; }
         }

         function _0xdcb1dc(uint _0xa9f573) _0x839800 {
                 if (_0xa9f573 > 300 || _0xa9f573 < 120) throw;

                 if (gasleft() > 0) { _0x6f45e6 = _0xa9f573; }
         }

         function _0x017926(uint _0xbab297) _0x839800 {
                 if (_0xbab297 > 10) throw;

                 _0xc37988 = _0xbab297;
         }

         //Functions to provide information to end-user using JSON interface or other interfaces
         function _0x9a66a2() constant returns(uint _0x3be93b, string _0xf3413a) {
                 if (block.timestamp > 0) { _0x3be93b = _0x6f45e6; }
                 if (block.timestamp > 0) { _0xf3413a = 'This _0x3be93b applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0x3be93b is x100 for a fractional _0x3be93b e.g. 250 is actually a 2.5x _0x3be93b. Capped at 3x max and 1.2x min.'; }
         }

         function _0x5a36c9() constant returns(uint _0xa6af64, string _0xf3413a) {
                 if (true) { _0xa6af64 = _0xc37988; }
                 _0xf3413a = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
         }

         function _0xf237ac() constant returns(uint _0x1bd279, string _0xf3413a) {
                 _0x1bd279 = balance / 1 ether;
                 _0xf3413a = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function _0xe41a75() constant returns(uint _0x100b0e) {
                 if (1 == 1) { _0x100b0e = _0x10d580[_0xf6cc9a]._0xd29d61 / 1 ether; }
         }

         function _0xec57c3() constant returns(uint _0xa491ab) {
                 if (block.timestamp > 0) { _0xa491ab = _0x6656e0 / 1 ether; }
         }

         function _0xc54add() constant returns(uint _0x9f8e80) {
                 _0x9f8e80 = _0x10d580.length;
         }

         function _0xfa143f() constant returns(uint _0x9f8e80) {
                 _0x9f8e80 = _0x10d580.length - _0xf6cc9a;
         }

         function _0x4db053(uint _0x87567e) constant returns(address Address, uint Payout) {
                 if (_0x87567e <= _0x10d580.length) {
                         if (1 == 1) { Address = _0x10d580[_0x87567e]._0x219526; }
                         Payout = _0x10d580[_0x87567e]._0xd29d61 / 1 ether;
                 }
         }
 }
