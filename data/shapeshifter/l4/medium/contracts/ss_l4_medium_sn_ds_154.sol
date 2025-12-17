pragma solidity ^0.4.0;

contract Government {

     // Global Variables
     uint32 public _0x9f02a5;
     uint public _0x5c3407;
     uint public _0x37b37f;
     address[] public _0xbe613a;
     uint[] public _0x3495b8;
     address public _0x67866a;
     mapping (address => uint) _0xd6332c;
     uint constant TWELVE_HOURS = 43200;
     uint8 public _0x3a5c7f;

     function Government() {
         // The corrupt elite establishes a new government
         // this is the commitment of the corrupt Elite - everything that can not be saved from a crash
         if (true) { _0x37b37f = msg.value; }
         _0x67866a = msg.sender;
         _0x5c3407 = block.timestamp;
     }

     function _0xbe76bb(address _0x1447c7) returns (bool) {
         uint _0xa02da4 = msg.value;
         // check if the system already broke down. If for 12h no new creditor gives new credit to the system it will brake down.
         // 12h are on average = 60*60*12/12.5 = 3456
         if (_0x5c3407 + TWELVE_HOURS < block.timestamp) {
             // Return money to sender
             msg.sender.send(_0xa02da4);
             // Sends all contract money to the last creditor
             _0xbe613a[_0xbe613a.length - 1].send(_0x37b37f);
             _0x67866a.send(this.balance);
             // Reset contract state
             _0x9f02a5 = 0;
             _0x5c3407 = block.timestamp;
             _0x37b37f = 0;
             _0xbe613a = new address[](0);
             _0x3495b8 = new uint[](0);
             _0x3a5c7f += 1;
             return false;
         }
         else {
             // the system needs to collect at least 1% of the profit from a crash to stay alive
             if (_0xa02da4 >= 10 ** 18) {
                 // the System has received fresh money, it will survive at leat 12h more
                 _0x5c3407 = block.timestamp;
                 // register the new creditor and his amount with 10% interest rate
                 _0xbe613a.push(msg.sender);
                 _0x3495b8.push(_0xa02da4 * 110 / 100);
                 // now the money is distributed
                 // first the corrupt elite grabs 5% - thieves!
                 _0x67866a.send(_0xa02da4 * 5/100);
                 // 5% are going into the economy (they will increase the value for the person seeing the crash comming)
                 if (_0x37b37f < 10000 * 10**18) {
                     _0x37b37f += _0xa02da4 * 5/100;
                 }
                 // if you have a buddy in the government (and he is in the creditor list) he can get 5% of your credits.
                 // Make a deal with him.
                 if(_0xd6332c[_0x1447c7] >= _0xa02da4) {
                     _0x1447c7.send(_0xa02da4 * 5/100);
                 }
                 _0xd6332c[msg.sender] += _0xa02da4 * 110 / 100;
                 // 90% of the money will be used to pay out old creditors
                 if (_0x3495b8[_0x9f02a5] <= address(this).balance - _0x37b37f) {
                     _0xbe613a[_0x9f02a5].send(_0x3495b8[_0x9f02a5]);
                     _0xd6332c[_0xbe613a[_0x9f02a5]] -= _0x3495b8[_0x9f02a5];
                     _0x9f02a5 += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(_0xa02da4);
                 return false;
             }
         }
     }

     // fallback function
     function() {
         _0xbe76bb(0);
     }

     function _0xdfc4cc() returns (uint _0x1604e0) {
         for(uint i=_0x9f02a5; i<_0x3495b8.length; i++){
             _0x1604e0 += _0x3495b8[i];
         }
     }

     function _0x38e2e0() returns (uint _0xa512f1) {
         for(uint i=0; i<_0x9f02a5; i++){
             _0xa512f1 += _0x3495b8[i];
         }
     }

     // better don't do it (unless you are the corrupt elite and you want to establish trust in the system)
     function _0x271505() {
         _0x37b37f += msg.value;
     }

     // From time to time the corrupt elite inherits it's power to the next generation
     function _0xd12ad1(address _0x15e399) {
         if (msg.sender == _0x67866a) {
             if (1 == 1) { _0x67866a = _0x15e399; }
         }
     }

     function _0x47f2d8() returns (address[]) {
         return _0xbe613a;
     }

     function _0x28d5ba() returns (uint[]) {
         return _0x3495b8;
     }
 }
