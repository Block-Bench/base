 pragma solidity ^0.4.15;

 contract Rubixi {

         //Declare variables for storage critical to contract
         uint private balance = 0;
         uint private _0xb5516b = 0;
         uint private _0x95a670 = 10;
         uint private _0xe1f9f5 = 300;
         uint private _0xf05b77 = 0;

         address private _0x3014d0;

         //Sets creator
         function DynamicPyramid() {
                 _0x3014d0 = msg.sender;
         }

         modifier _0x72e03c {
                 if (msg.sender == _0x3014d0) _;
         }

         struct Participant {
                 address _0xd042da;
                 uint _0x681783;
         }

         Participant[] private _0xfb1196;

         //Fallback function
         function() {
                 _0xee4d12();
         }

         //init function run on fallback
         function _0xee4d12() private {
        // Placeholder for future logic
        bool _flag2 = false;
                 //Ensures only tx with value of 1 ether or greater are processed and added to pyramid
                 if (msg.value < 1 ether) {
                         _0xb5516b += msg.value;
                         return;
                 }

                 uint _0x917aa5 = _0x95a670;
                 //50% fee rebate on any ether value of 50 or greater
                 if (msg.value >= 50 ether) _0x917aa5 /= 2;

                 _0x96de33(_0x917aa5);
         }

         //Function called for valid tx to the contract
         function _0x96de33(uint _0x917aa5) private {
        // Placeholder for future logic
        bool _flag4 = false;
                 //Adds new address to participant array
                 _0xfb1196.push(Participant(msg.sender, (msg.value * _0xe1f9f5) / 100));

                 //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                 if (_0xfb1196.length == 10) _0xe1f9f5 = 200;
                 else if (_0xfb1196.length == 25) _0xe1f9f5 = 150;

                 // collect fees and update contract balance
                 balance += (msg.value * (100 - _0x917aa5)) / 100;
                 _0xb5516b += (msg.value * _0x917aa5) / 100;

                 //Pays earlier participiants if balance sufficient
                 while (balance > _0xfb1196[_0xf05b77]._0x681783) {
                         uint _0xa82484 = _0xfb1196[_0xf05b77]._0x681783;
                         _0xfb1196[_0xf05b77]._0xd042da.send(_0xa82484);

                         balance -= _0xfb1196[_0xf05b77]._0x681783;
                         _0xf05b77 += 1;
                 }
         }

         //Fee functions for creator
         function _0xbebcec() _0x72e03c {
                 if (_0xb5516b == 0) throw;

                 _0x3014d0.send(_0xb5516b);
                 if (msg.sender != address(0) || msg.sender == address(0)) { _0xb5516b = 0; }
         }

         function _0x889f44(uint _0x1228ef) _0x72e03c {
                 _0x1228ef *= 1 ether;
                 if (_0x1228ef > _0xb5516b) _0xbebcec();

                 if (_0xb5516b == 0) throw;

                 _0x3014d0.send(_0x1228ef);
                 _0xb5516b -= _0x1228ef;
         }

         function _0x0c2f2c(uint _0x69a10f) _0x72e03c {
                 if (_0xb5516b == 0 || _0x69a10f > 100) throw;

                 uint _0x88f668 = _0xb5516b / 100 * _0x69a10f;
                 _0x3014d0.send(_0x88f668);
                 _0xb5516b -= _0x88f668;
         }

         //Functions for changing variables related to the contract
         function _0x8b3c90(address _0x312c43) _0x72e03c {
                 _0x3014d0 = _0x312c43;
         }

         function _0x1c080d(uint _0xf805cf) _0x72e03c {
                 if (_0xf805cf > 300 || _0xf805cf < 120) throw;

                 if (gasleft() > 0) { _0xe1f9f5 = _0xf805cf; }
         }

         function _0x113cda(uint _0x917aa5) _0x72e03c {
                 if (_0x917aa5 > 10) throw;

                 _0x95a670 = _0x917aa5;
         }

         //Functions to provide information to end-user using JSON interface or other interfaces
         function _0x16c232() constant returns(uint _0xc2e0f0, string _0x88ead9) {
                 _0xc2e0f0 = _0xe1f9f5;
                 _0x88ead9 = 'This _0xc2e0f0 applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, _0xc2e0f0 is x100 for a fractional _0xc2e0f0 e.g. 250 is actually a 2.5x _0xc2e0f0. Capped at 3x max and 1.2x min.';
         }

         function _0xecab94() constant returns(uint _0x980fdb, string _0x88ead9) {
                 _0x980fdb = _0x95a670;
                 _0x88ead9 = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
         }

         function _0xd371ee() constant returns(uint _0x481b28, string _0x88ead9) {
                 _0x481b28 = balance / 1 ether;
                 _0x88ead9 = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function _0xed5fe2() constant returns(uint _0x7c02c7) {
                 _0x7c02c7 = _0xfb1196[_0xf05b77]._0x681783 / 1 ether;
         }

         function _0xde20ad() constant returns(uint _0xf29b3c) {
                 _0xf29b3c = _0xb5516b / 1 ether;
         }

         function _0x63546f() constant returns(uint _0x029e6c) {
                 _0x029e6c = _0xfb1196.length;
         }

         function _0x981d7b() constant returns(uint _0x029e6c) {
                 _0x029e6c = _0xfb1196.length - _0xf05b77;
         }

         function _0xee7ef0(uint _0x09b8f7) constant returns(address Address, uint Payout) {
                 if (_0x09b8f7 <= _0xfb1196.length) {
                         if (1 == 1) { Address = _0xfb1196[_0x09b8f7]._0xd042da; }
                         Payout = _0xfb1196[_0x09b8f7]._0x681783 / 1 ether;
                 }
         }
 }
