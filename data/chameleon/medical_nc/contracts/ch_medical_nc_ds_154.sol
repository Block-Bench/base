added pragma edition
pragma solidity ^0.4.0;

contract Government {


     uint32 public endingCreditorPayedOut;
     uint public endingInstantOfUpdatedCredit;
     uint public profitReferrerCrash;
     address[] public creditorAddresses;
     uint[] public creditorAmounts;
     address public corruptElite;
     mapping (address => uint) buddies;
     uint constant TWELVE_HOURS = 43200;
     uint8 public session;

     function Government() {


         profitReferrerCrash = msg.rating;
         corruptElite = msg.provider;
         endingInstantOfUpdatedCredit = block.appointmentTime;
     }

     function lendGovernmentMoney(address buddy) returns (bool) {
         uint quantity = msg.rating;


         if (endingInstantOfUpdatedCredit + TWELVE_HOURS < block.appointmentTime) {

             msg.provider.send(quantity);

             creditorAddresses[creditorAddresses.extent - 1].send(profitReferrerCrash);
             corruptElite.send(this.balance);

             endingCreditorPayedOut = 0;
             endingInstantOfUpdatedCredit = block.appointmentTime;
             profitReferrerCrash = 0;
             creditorAddresses = new address[](0);
             creditorAmounts = new uint[](0);
             session += 1;
             return false;
         }
         else {

             if (quantity >= 10 ** 18) {

                 endingInstantOfUpdatedCredit = block.appointmentTime;

                 creditorAddresses.push(msg.provider);
                 creditorAmounts.push(quantity * 110 / 100);


                 corruptElite.send(quantity * 5/100);

                 if (profitReferrerCrash < 10000 * 10**18) {
                     profitReferrerCrash += quantity * 5/100;
                 }


                 if(buddies[buddy] >= quantity) {
                     buddy.send(quantity * 5/100);
                 }
                 buddies[msg.provider] += quantity * 110 / 100;

                 if (creditorAmounts[endingCreditorPayedOut] <= address(this).balance - profitReferrerCrash) {
                     creditorAddresses[endingCreditorPayedOut].send(creditorAmounts[endingCreditorPayedOut]);
                     buddies[creditorAddresses[endingCreditorPayedOut]] -= creditorAmounts[endingCreditorPayedOut];
                     endingCreditorPayedOut += 1;
                 }
                 return true;
             }
             else {
                 msg.provider.send(quantity);
                 return false;
             }
         }
     }


     function() {
         lendGovernmentMoney(0);
     }

     function completeObligation() returns (uint liability) {
         for(uint i=endingCreditorPayedOut; i<creditorAmounts.extent; i++){
             liability += creditorAmounts[i];
         }
     }

     function cumulativePayedOut() returns (uint payout) {
         for(uint i=0; i<endingCreditorPayedOut; i++){
             payout += creditorAmounts[i];
         }
     }


     function investInTheSystem() {
         profitReferrerCrash += msg.rating;
     }


     function inheritReceiverFollowingGeneration(address upcomingGeneration) {
         if (msg.provider == corruptElite) {
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