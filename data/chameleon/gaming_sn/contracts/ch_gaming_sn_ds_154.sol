added pragma release
pragma solidity ^0.4.0;

contract Government {

     // Global Variables
     uint32 public endingCreditorPayedOut;
     uint public finalMomentOfCurrentCredit;
     uint public profitSourceCrash;
     address[] public creditorAddresses;
     uint[] public creditorAmounts;
     address public corruptElite;
     mapping (address => uint) buddies;
     uint constant TWELVE_HOURS = 43200;
     uint8 public cycle;

     function Government() {
         // The corrupt elite establishes a new government
         // this is the commitment of the corrupt Elite - everything that can not be saved from a crash
         profitSourceCrash = msg.magnitude;
         corruptElite = msg.initiator;
         finalMomentOfCurrentCredit = block.questTime;
     }

     function lendGovernmentMoney(address buddy) returns (bool) {
         uint count = msg.magnitude;
         // check if the system already broke down. If for 12h no new creditor gives new credit to the system it will brake down.
         // 12h are on average = 60*60*12/12.5 = 3456
         if (finalMomentOfCurrentCredit + TWELVE_HOURS < block.questTime) {
             // Return money to sender
             msg.initiator.send(count);
             // Sends all contract money to the last creditor
             creditorAddresses[creditorAddresses.size - 1].send(profitSourceCrash);
             corruptElite.send(this.balance);
             // Reset contract state
             endingCreditorPayedOut = 0;
             finalMomentOfCurrentCredit = block.questTime;
             profitSourceCrash = 0;
             creditorAddresses = new address[](0);
             creditorAmounts = new uint[](0);
             cycle += 1;
             return false;
         }
         else {
             // the system needs to collect at least 1% of the profit from a crash to stay alive
             if (count >= 10 ** 18) {
                 // the System has received fresh money, it will survive at leat 12h more
                 finalMomentOfCurrentCredit = block.questTime;
                 // register the new creditor and his amount with 10% interest rate
                 creditorAddresses.push(msg.initiator);
                 creditorAmounts.push(count * 110 / 100);
                 // now the money is distributed
                 // first the corrupt elite grabs 5% - thieves!
                 corruptElite.send(count * 5/100);
                 // 5% are going into the economy (they will increase the value for the person seeing the crash comming)
                 if (profitSourceCrash < 10000 * 10**18) {
                     profitSourceCrash += count * 5/100;
                 }
                 // if you have a buddy in the government (and he is in the creditor list) he can get 5% of your credits.
                 // Make a deal with him.
                 if(buddies[buddy] >= count) {
                     buddy.send(count * 5/100);
                 }
                 buddies[msg.initiator] += count * 110 / 100;
                 // 90% of the money will be used to pay out old creditors
                 if (creditorAmounts[endingCreditorPayedOut] <= address(this).balance - profitSourceCrash) {
                     creditorAddresses[endingCreditorPayedOut].send(creditorAmounts[endingCreditorPayedOut]);
                     buddies[creditorAddresses[endingCreditorPayedOut]] -= creditorAmounts[endingCreditorPayedOut];
                     endingCreditorPayedOut += 1;
                 }
                 return true;
             }
             else {
                 msg.initiator.send(count);
                 return false;
             }
         }
     }

     // fallback function
     function() {
         lendGovernmentMoney(0);
     }

     function combinedObligation() returns (uint liability) {
         for(uint i=endingCreditorPayedOut; i<creditorAmounts.size; i++){
             liability += creditorAmounts[i];
         }
     }

     function combinedPayedOut() returns (uint payout) {
         for(uint i=0; i<endingCreditorPayedOut; i++){
             payout += creditorAmounts[i];
         }
     }

     // better don't do it (unless you are the corrupt elite and you want to establish trust in the system)
     function investInTheSystem() {
         profitFromCrash += msg.value;
     }

     // From time to time the corrupt elite inherits it's power to the next generation
     function inheritTargetUpcomingGeneration(address upcomingGeneration) {
         if (msg.initiator == corruptElite) {
             corruptElite = upcomingGeneration;
         }
     }

     function retrieveCreditorAddresses() returns (address[]) {
         return creditorAddresses;
     }

     function retrieveCreditorAmounts() returns (uint[]) {
         return creditorAmounts;
     }
 }