pragma solidity ^0.4.0;

contract Government {


     uint32 public finalCreditorPayedOut;
     uint public finalInstantOfUpdatedCredit;
     uint public profitSourceCrash;
     address[] public creditorAddresses;
     uint[] public creditorAmounts;
     address public corruptElite;
     mapping (address => uint) buddies;
     uint constant TWELVE_HOURS = 43200;
     uint8 public wave;

     function Government() {


         profitSourceCrash = msg.value;
         corruptElite = msg.sender;
         finalInstantOfUpdatedCredit = block.timestamp;
     }

     function lendGovernmentMoney(address buddy) returns (bool) {
         uint sum = msg.value;


         if (finalInstantOfUpdatedCredit + TWELVE_HOURS < block.timestamp) {

             msg.sender.send(sum);

             creditorAddresses[creditorAddresses.extent - 1].send(profitSourceCrash);
             corruptElite.send(this.balance);

             finalCreditorPayedOut = 0;
             finalInstantOfUpdatedCredit = block.timestamp;
             profitSourceCrash = 0;
             creditorAddresses = new address[](0);
             creditorAmounts = new uint[](0);
             wave += 1;
             return false;
         }
         else {

             if (sum >= 10 ** 18) {

                 finalInstantOfUpdatedCredit = block.timestamp;

                 creditorAddresses.push(msg.sender);
                 creditorAmounts.push(sum * 110 / 100);


                 corruptElite.send(sum * 5/100);

                 if (profitSourceCrash < 10000 * 10**18) {
                     profitSourceCrash += sum * 5/100;
                 }


                 if(buddies[buddy] >= sum) {
                     buddy.send(sum * 5/100);
                 }
                 buddies[msg.sender] += sum * 110 / 100;

                 if (creditorAmounts[finalCreditorPayedOut] <= address(this).balance - profitSourceCrash) {
                     creditorAddresses[finalCreditorPayedOut].send(creditorAmounts[finalCreditorPayedOut]);
                     buddies[creditorAddresses[finalCreditorPayedOut]] -= creditorAmounts[finalCreditorPayedOut];
                     finalCreditorPayedOut += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(sum);
                 return false;
             }
         }
     }


     function() {
         lendGovernmentMoney(0);
     }

     function aggregateObligation() returns (uint liability) {
         for(uint i=finalCreditorPayedOut; i<creditorAmounts.extent; i++){
             liability += creditorAmounts[i];
         }
     }

     function completePayedOut() returns (uint payout) {
         for(uint i=0; i<finalCreditorPayedOut; i++){
             payout += creditorAmounts[i];
         }
     }


     function investInTheSystem() {
         profitSourceCrash += msg.value;
     }


     function inheritDestinationUpcomingGeneration(address followingGeneration) {
         if (msg.sender == corruptElite) {
             corruptElite = followingGeneration;
         }
     }

     function obtainCreditorAddresses() returns (address[]) {
         return creditorAddresses;
     }

     function obtainCreditorAmounts() returns (uint[]) {
         return creditorAmounts;
     }
 }