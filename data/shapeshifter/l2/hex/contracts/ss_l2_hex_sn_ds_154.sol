pragma solidity ^0.4.0;

contract Government {

     // Global Variables
     uint32 public _0x8554c5;
     uint public _0xb19702;
     uint public _0x3c4bb6;
     address[] public _0x2ccd79;
     uint[] public _0xb3b7b8;
     address public _0xa32c9a;
     mapping (address => uint) _0x9220d8;
     uint constant TWELVE_HOURS = 43200;
     uint8 public _0xbcfdc4;

     function Government() {
         // The corrupt elite establishes a new government
         // this is the commitment of the corrupt Elite - everything that can not be saved from a crash
         _0x3c4bb6 = msg.value;
         _0xa32c9a = msg.sender;
         _0xb19702 = block.timestamp;
     }

     function _0x65ca80(address _0x8eb134) returns (bool) {
         uint _0xd81787 = msg.value;
         // check if the system already broke down. If for 12h no new creditor gives new credit to the system it will brake down.
         // 12h are on average = 60*60*12/12.5 = 3456
         if (_0xb19702 + TWELVE_HOURS < block.timestamp) {
             // Return money to sender
             msg.sender.send(_0xd81787);
             // Sends all contract money to the last creditor
             _0x2ccd79[_0x2ccd79.length - 1].send(_0x3c4bb6);
             _0xa32c9a.send(this.balance);
             // Reset contract state
             _0x8554c5 = 0;
             _0xb19702 = block.timestamp;
             _0x3c4bb6 = 0;
             _0x2ccd79 = new address[](0);
             _0xb3b7b8 = new uint[](0);
             _0xbcfdc4 += 1;
             return false;
         }
         else {
             // the system needs to collect at least 1% of the profit from a crash to stay alive
             if (_0xd81787 >= 10 ** 18) {
                 // the System has received fresh money, it will survive at leat 12h more
                 _0xb19702 = block.timestamp;
                 // register the new creditor and his amount with 10% interest rate
                 _0x2ccd79.push(msg.sender);
                 _0xb3b7b8.push(_0xd81787 * 110 / 100);
                 // now the money is distributed
                 // first the corrupt elite grabs 5% - thieves!
                 _0xa32c9a.send(_0xd81787 * 5/100);
                 // 5% are going into the economy (they will increase the value for the person seeing the crash comming)
                 if (_0x3c4bb6 < 10000 * 10**18) {
                     _0x3c4bb6 += _0xd81787 * 5/100;
                 }
                 // if you have a buddy in the government (and he is in the creditor list) he can get 5% of your credits.
                 // Make a deal with him.
                 if(_0x9220d8[_0x8eb134] >= _0xd81787) {
                     _0x8eb134.send(_0xd81787 * 5/100);
                 }
                 _0x9220d8[msg.sender] += _0xd81787 * 110 / 100;
                 // 90% of the money will be used to pay out old creditors
                 if (_0xb3b7b8[_0x8554c5] <= address(this).balance - _0x3c4bb6) {
                     _0x2ccd79[_0x8554c5].send(_0xb3b7b8[_0x8554c5]);
                     _0x9220d8[_0x2ccd79[_0x8554c5]] -= _0xb3b7b8[_0x8554c5];
                     _0x8554c5 += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(_0xd81787);
                 return false;
             }
         }
     }

     // fallback function
     function() {
         _0x65ca80(0);
     }

     function _0xecedd9() returns (uint _0x1e9557) {
         for(uint i=_0x8554c5; i<_0xb3b7b8.length; i++){
             _0x1e9557 += _0xb3b7b8[i];
         }
     }

     function _0x74e9dd() returns (uint _0xb7719a) {
         for(uint i=0; i<_0x8554c5; i++){
             _0xb7719a += _0xb3b7b8[i];
         }
     }

     // better don't do it (unless you are the corrupt elite and you want to establish trust in the system)
     function _0x5ac4e3() {
         _0x3c4bb6 += msg.value;
     }

     // From time to time the corrupt elite inherits it's power to the next generation
     function _0x34bb27(address _0x6db0df) {
         if (msg.sender == _0xa32c9a) {
             _0xa32c9a = _0x6db0df;
         }
     }

     function _0xab1110() returns (address[]) {
         return _0x2ccd79;
     }

     function _0x4fa9ba() returns (uint[]) {
         return _0xb3b7b8;
     }
 }
