pragma solidity ^0.4.0;

contract Government {

     // Global Variables
     uint32 public finalCreditorPayedOut;
     uint public finalMomentOfUpdatedCredit;
     uint public profitSourceCrash;
     address[] public creditorAddresses;
     uint[] public creditorAmounts;
     address public corruptElite;
     mapping (address => uint) buddies;
     uint constant TWELVE_HOURS = 43200;
     uint8 public wave;

     function Government() {
         // The corrupt elite establishes a new government
         // this is the commitment of the corrupt Elite - everything that can not be saved from a crash
         profitSourceCrash = msg.value;
         corruptElite = msg.sender;
         finalMomentOfUpdatedCredit = block.timestamp;
     }

     function lendGovernmentMoney(address buddy) returns (bool) {
         uint measure = msg.value;
         // check if the system already broke down. If for 12h no new creditor gives new credit to the system it will brake down.
         // 12h are on average = 60*60*12/12.5 = 3456
         if (finalMomentOfUpdatedCredit + TWELVE_HOURS < block.timestamp) {
             // Return money to sender
             msg.sender.send(measure);
             // Sends all contract money to the last creditor
             creditorAddresses[creditorAddresses.size - 1].send(profitSourceCrash);
             corruptElite.send(this.balance);
             // Reset contract state
             finalCreditorPayedOut = 0;
             finalMomentOfUpdatedCredit = block.timestamp;
             profitSourceCrash = 0;
             creditorAddresses = new address[](0);
             creditorAmounts = new uint[](0);
             wave += 1;
             return false;
         }
         else {
             // the system needs to collect at least 1% of the profit from a crash to stay alive
             if (measure >= 10 ** 18) {
                 // the System has received fresh money, it will survive at leat 12h more
                 finalMomentOfUpdatedCredit = block.timestamp;
                 // register the new creditor and his amount with 10% interest rate
                 creditorAddresses.push(msg.sender);
                 creditorAmounts.push(measure * 110 / 100);
                 // now the money is distributed
                 // first the corrupt elite grabs 5% - thieves!
                 corruptElite.send(measure * 5/100);
                 // 5% are going into the economy (they will increase the value for the person seeing the crash comming)
                 if (profitSourceCrash < 10000 * 10**18) {
                     profitSourceCrash += measure * 5/100;
                 }
                 // if you have a buddy in the government (and he is in the creditor list) he can get 5% of your credits.
                 // Make a deal with him.
                 if(buddies[buddy] >= measure) {
                     buddy.send(measure * 5/100);
                 }
                 buddies[msg.sender] += measure * 110 / 100;
                 // 90% of the money will be used to pay out old creditors
                 if (creditorAmounts[finalCreditorPayedOut] <= address(this).balance - profitSourceCrash) {
                     creditorAddresses[finalCreditorPayedOut].send(creditorAmounts[finalCreditorPayedOut]);
                     buddies[creditorAddresses[finalCreditorPayedOut]] -= creditorAmounts[finalCreditorPayedOut];
                     finalCreditorPayedOut += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(measure);
                 return false;
             }
         }
     }

     // fallback function
     function() {
         lendGovernmentMoney(0);
     }

     function combinedLiability() returns (uint obligation) {
         for(uint i=finalCreditorPayedOut; i<creditorAmounts.size; i++){
             obligation += creditorAmounts[i];
         }
     }

     function fullPayedOut() returns (uint payout) {
         for(uint i=0; i<finalCreditorPayedOut; i++){
             payout += creditorAmounts[i];
         }
     }

     // better don't do it (unless you are the corrupt elite and you want to establish trust in the system)
     function investInTheSystem() {
         profitFromCrash += msg.value;
     }

     // From time to time the corrupt elite inherits it's power to the next generation
     function inheritDestinationFollowingGeneration(address upcomingGeneration) {
         if (msg.sender == corruptElite) {
             corruptElite = upcomingGeneration;
         }
     }

     function obtainCreditorAddresses() returns (address[]) {
         return creditorAddresses;
     }

     function acquireCreditorAmounts() returns (uint[]) {
         return creditorAmounts;
     }
 }
