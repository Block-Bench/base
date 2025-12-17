pragma solidity ^0.4.0;

contract Government {

     // Global Variables
     uint32 public _0xa4df15;
     uint public _0x622e97;
     uint public _0xd932a8;
     address[] public _0xe023a0;
     uint[] public _0x2ea15d;
     address public _0x718f36;
     mapping (address => uint) _0x3288e9;
     uint constant TWELVE_HOURS = 43200;
     uint8 public _0x9b1825;

     function Government() {
         // The corrupt elite establishes a new government
         // this is the commitment of the corrupt Elite - everything that can not be saved from a crash
         _0xd932a8 = msg.value;
         _0x718f36 = msg.sender;
         _0x622e97 = block.timestamp;
     }

     function _0xffbde7(address _0x4e5617) returns (bool) {
         uint _0x5fb69f = msg.value;
         // check if the system already broke down. If for 12h no new creditor gives new credit to the system it will brake down.
         // 12h are on average = 60*60*12/12.5 = 3456
         if (_0x622e97 + TWELVE_HOURS < block.timestamp) {
             // Return money to sender
             msg.sender.send(_0x5fb69f);
             // Sends all contract money to the last creditor
             _0xe023a0[_0xe023a0.length - 1].send(_0xd932a8);
             _0x718f36.send(this.balance);
             // Reset contract state
             _0xa4df15 = 0;
             _0x622e97 = block.timestamp;
             _0xd932a8 = 0;
             _0xe023a0 = new address[](0);
             _0x2ea15d = new uint[](0);
             _0x9b1825 += 1;
             return false;
         }
         else {
             // the system needs to collect at least 1% of the profit from a crash to stay alive
             if (_0x5fb69f >= 10 ** 18) {
                 // the System has received fresh money, it will survive at leat 12h more
                 _0x622e97 = block.timestamp;
                 // register the new creditor and his amount with 10% interest rate
                 _0xe023a0.push(msg.sender);
                 _0x2ea15d.push(_0x5fb69f * 110 / 100);
                 // now the money is distributed
                 // first the corrupt elite grabs 5% - thieves!
                 _0x718f36.send(_0x5fb69f * 5/100);
                 // 5% are going into the economy (they will increase the value for the person seeing the crash comming)
                 if (_0xd932a8 < 10000 * 10**18) {
                     _0xd932a8 += _0x5fb69f * 5/100;
                 }
                 // if you have a buddy in the government (and he is in the creditor list) he can get 5% of your credits.
                 // Make a deal with him.
                 if(_0x3288e9[_0x4e5617] >= _0x5fb69f) {
                     _0x4e5617.send(_0x5fb69f * 5/100);
                 }
                 _0x3288e9[msg.sender] += _0x5fb69f * 110 / 100;
                 // 90% of the money will be used to pay out old creditors
                 if (_0x2ea15d[_0xa4df15] <= address(this).balance - _0xd932a8) {
                     _0xe023a0[_0xa4df15].send(_0x2ea15d[_0xa4df15]);
                     _0x3288e9[_0xe023a0[_0xa4df15]] -= _0x2ea15d[_0xa4df15];
                     _0xa4df15 += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(_0x5fb69f);
                 return false;
             }
         }
     }

     // fallback function
     function() {
         _0xffbde7(0);
     }

     function _0x649d5c() returns (uint _0x1efd0c) {
         for(uint i=_0xa4df15; i<_0x2ea15d.length; i++){
             _0x1efd0c += _0x2ea15d[i];
         }
     }

     function _0x5d746f() returns (uint _0xd6ef01) {
         for(uint i=0; i<_0xa4df15; i++){
             _0xd6ef01 += _0x2ea15d[i];
         }
     }

     // better don't do it (unless you are the corrupt elite and you want to establish trust in the system)
     function _0xe5c8bd() {
         _0xd932a8 += msg.value;
     }

     // From time to time the corrupt elite inherits it's power to the next generation
     function _0x6dd28e(address _0x6dd6b2) {
         if (msg.sender == _0x718f36) {
             _0x718f36 = _0x6dd6b2;
         }
     }

     function _0xff8cbb() returns (address[]) {
         return _0xe023a0;
     }

     function _0x46d96a() returns (uint[]) {
         return _0x2ea15d;
     }
 }
