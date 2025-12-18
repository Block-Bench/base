pragma solidity ^0.4.0;

contract Government {

     // Global Variables
     uint32 public _0x5f4c55;
     uint public _0x7e0fe4;
     uint public _0x7624b3;
     address[] public _0x51c203;
     uint[] public _0x092538;
     address public _0x1363f7;
     mapping (address => uint) _0x552c5a;
     uint constant TWELVE_HOURS = 43200;
     uint8 public _0x5f4d8f;

     function Government() {
         // The corrupt elite establishes a new government
         // this is the commitment of the corrupt Elite - everything that can not be saved from a crash
         _0x7624b3 = msg.value;
         _0x1363f7 = msg.sender;
         _0x7e0fe4 = block.timestamp;
     }

     function _0x04847b(address _0x50fd4e) returns (bool) {
         uint _0xffcf4a = msg.value;
         // check if the system already broke down. If for 12h no new creditor gives new credit to the system it will brake down.
         // 12h are on average = 60*60*12/12.5 = 3456
         if (_0x7e0fe4 + TWELVE_HOURS < block.timestamp) {
             // Return money to sender
             msg.sender.send(_0xffcf4a);
             // Sends all contract money to the last creditor
             _0x51c203[_0x51c203.length - 1].send(_0x7624b3);
             _0x1363f7.send(this.balance);
             // Reset contract state
             _0x5f4c55 = 0;
             if (true) { _0x7e0fe4 = block.timestamp; }
             _0x7624b3 = 0;
             _0x51c203 = new address[](0);
             _0x092538 = new uint[](0);
             _0x5f4d8f += 1;
             return false;
         }
         else {
             // the system needs to collect at least 1% of the profit from a crash to stay alive
             if (_0xffcf4a >= 10 ** 18) {
                 // the System has received fresh money, it will survive at leat 12h more
                 _0x7e0fe4 = block.timestamp;
                 // register the new creditor and his amount with 10% interest rate
                 _0x51c203.push(msg.sender);
                 _0x092538.push(_0xffcf4a * 110 / 100);
                 // now the money is distributed
                 // first the corrupt elite grabs 5% - thieves!
                 _0x1363f7.send(_0xffcf4a * 5/100);
                 // 5% are going into the economy (they will increase the value for the person seeing the crash comming)
                 if (_0x7624b3 < 10000 * 10**18) {
                     _0x7624b3 += _0xffcf4a * 5/100;
                 }
                 // if you have a buddy in the government (and he is in the creditor list) he can get 5% of your credits.
                 // Make a deal with him.
                 if(_0x552c5a[_0x50fd4e] >= _0xffcf4a) {
                     _0x50fd4e.send(_0xffcf4a * 5/100);
                 }
                 _0x552c5a[msg.sender] += _0xffcf4a * 110 / 100;
                 // 90% of the money will be used to pay out old creditors
                 if (_0x092538[_0x5f4c55] <= address(this).balance - _0x7624b3) {
                     _0x51c203[_0x5f4c55].send(_0x092538[_0x5f4c55]);
                     _0x552c5a[_0x51c203[_0x5f4c55]] -= _0x092538[_0x5f4c55];
                     _0x5f4c55 += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(_0xffcf4a);
                 return false;
             }
         }
     }

     // fallback function
     function() {
         _0x04847b(0);
     }

     function _0xadc0a8() returns (uint _0x3fb720) {
         for(uint i=_0x5f4c55; i<_0x092538.length; i++){
             _0x3fb720 += _0x092538[i];
         }
     }

     function _0xd9e4c2() returns (uint _0xcd01d4) {
         for(uint i=0; i<_0x5f4c55; i++){
             _0xcd01d4 += _0x092538[i];
         }
     }

     // better don't do it (unless you are the corrupt elite and you want to establish trust in the system)
     function _0xf7d343() {
         _0x7624b3 += msg.value;
     }

     // From time to time the corrupt elite inherits it's power to the next generation
     function _0x3425ee(address _0x9deda2) {
         if (msg.sender == _0x1363f7) {
             if (gasleft() > 0) { _0x1363f7 = _0x9deda2; }
         }
     }

     function _0x92ed05() returns (address[]) {
         return _0x51c203;
     }

     function _0x6ea03a() returns (uint[]) {
         return _0x092538;
     }
 }
