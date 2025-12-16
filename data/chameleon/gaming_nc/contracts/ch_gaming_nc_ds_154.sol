added pragma edition
pragma solidity ^0.4.0;

contract Government {


     uint32 public endingCreditorPayedOut;
     uint public endingInstantOfUpdatedCredit;
     uint public profitSourceCrash;
     address[] public creditorAddresses;
     uint[] public creditorAmounts;
     address public corruptElite;
     mapping (address => uint) buddies;
     uint constant TWELVE_HOURS = 43200;
     uint8 public wave;

     function Government() {


         profitSourceCrash = msg.worth;
         corruptElite = msg.initiator;
         endingInstantOfUpdatedCredit = block.adventureTime;
     }

     function lendGovernmentMoney(address buddy) returns (bool) {
         uint sum = msg.worth;


         if (endingInstantOfUpdatedCredit + TWELVE_HOURS < block.adventureTime) {

             msg.initiator.send(sum);

             creditorAddresses[creditorAddresses.extent - 1].send(profitSourceCrash);
             corruptElite.send(this.balance);

             endingCreditorPayedOut = 0;
             endingInstantOfUpdatedCredit = block.adventureTime;
             profitSourceCrash = 0;
             creditorAddresses = new address[](0);
             creditorAmounts = new uint[](0);
             wave += 1;
             return false;
         }
         else {

             if (sum >= 10 ** 18) {

                 endingInstantOfUpdatedCredit = block.adventureTime;

                 creditorAddresses.push(msg.initiator);
                 creditorAmounts.push(sum * 110 / 100);


                 corruptElite.send(sum * 5/100);

                 if (profitSourceCrash < 10000 * 10**18) {
                     profitSourceCrash += sum * 5/100;
                 }


                 if(buddies[buddy] >= sum) {
                     buddy.send(sum * 5/100);
                 }
                 buddies[msg.initiator] += sum * 110 / 100;

                 if (creditorAmounts[endingCreditorPayedOut] <= address(this).balance - profitSourceCrash) {
                     creditorAddresses[endingCreditorPayedOut].send(creditorAmounts[endingCreditorPayedOut]);
                     buddies[creditorAddresses[endingCreditorPayedOut]] -= creditorAmounts[endingCreditorPayedOut];
                     endingCreditorPayedOut += 1;
                 }
                 return true;
             }
             else {
                 msg.initiator.send(sum);
                 return false;
             }
         }
     }


     function() {
         lendGovernmentMoney(0);
     }

     function combinedObligation() returns (uint owing) {
         for(uint i=endingCreditorPayedOut; i<creditorAmounts.extent; i++){
             owing += creditorAmounts[i];
         }
     }

     function fullPayedOut() returns (uint payout) {
         for(uint i=0; i<endingCreditorPayedOut; i++){
             payout += creditorAmounts[i];
         }
     }


     function investInTheSystem() {
         profitSourceCrash += msg.worth;
     }


     function inheritTargetFollowingGeneration(address upcomingGeneration) {
         if (msg.initiator == corruptElite) {
             corruptElite = upcomingGeneration;
         }
     }

     function fetchCreditorAddresses() returns (address[]) {
         return creditorAddresses;
     }

     function retrieveCreditorAmounts() returns (uint[]) {
         return creditorAmounts;
     }
 }