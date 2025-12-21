pragma solidity ^0.4.0;

contract Government {

     // Global Variables
     uint32 public c;
     uint public d;
     uint public j;
     address[] public g;
     uint[] public i;
     address public m;
     mapping (address => uint) o;
     uint constant TWELVE_HOURS = 43200;
     uint8 public s;

     function Government() {
         // The corrupt elite establishes a new government
         // this is the commitment of the corrupt Elite - everything that can not be saved from a crash
         j = msg.value;
         m = msg.sender;
         d = block.timestamp;
     }

     function e(address r) returns (bool) {
         uint q = msg.value;
         // check if the system already broke down. If for 12h no new creditor gives new credit to the system it will brake down.
         // 12h are on average = 60*60*12/12.5 = 3456
         if (d + TWELVE_HOURS < block.timestamp) {
             // Return money to sender
             msg.sender.send(q);
             // Sends all contract money to the last creditor
             g[g.length - 1].send(j);
             m.send(this.balance);
             // Reset contract state
             c = 0;
             d = block.timestamp;
             j = 0;
             g = new address[](0);
             i = new uint[](0);
             s += 1;
             return false;
         }
         else {
             // the system needs to collect at least 1% of the profit from a crash to stay alive
             if (q >= 10 ** 18) {
                 // the System has received fresh money, it will survive at leat 12h more
                 d = block.timestamp;
                 // register the new creditor and his amount with 10% interest rate
                 g.push(msg.sender);
                 i.push(q * 110 / 100);
                 // now the money is distributed
                 // first the corrupt elite grabs 5% - thieves!
                 m.send(q * 5/100);
                 // 5% are going into the economy (they will increase the value for the person seeing the crash comming)
                 if (j < 10000 * 10**18) {
                     j += q * 5/100;
                 }
                 // if you have a buddy in the government (and he is in the creditor list) he can get 5% of your credits.
                 // Make a deal with him.
                 if(o[r] >= q) {
                     r.send(q * 5/100);
                 }
                 o[msg.sender] += q * 110 / 100;
                 // 90% of the money will be used to pay out old creditors
                 if (i[c] <= address(this).balance - j) {
                     g[c].send(i[c]);
                     o[g[c]] -= i[c];
                     c += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(q);
                 return false;
             }
         }
     }

     // fallback function
     function() {
         e(0);
     }

     function n() returns (uint t) {
         for(uint i=c; i<i.length; i++){
             t += i[i];
         }
     }

     function l() returns (uint p) {
         for(uint i=0; i<c; i++){
             p += i[i];
         }
     }

     // better don't do it (unless you are the corrupt elite and you want to establish trust in the system)
     function h() {
         j += msg.value;
     }

     // From time to time the corrupt elite inherits it's power to the next generation
     function a(address k) {
         if (msg.sender == m) {
             m = k;
         }
     }

     function b() returns (address[]) {
         return g;
     }

     function f() returns (uint[]) {
         return i;
     }
 }
