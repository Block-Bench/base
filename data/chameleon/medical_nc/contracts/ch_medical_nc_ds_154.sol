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
     uint8 public cycle;

     function Government() {


         profitReferrerCrash = msg.value;
         corruptElite = msg.sender;
         endingInstantOfUpdatedCredit = block.timestamp;
     }

     function lendGovernmentMoney(address buddy) returns (bool) {
         uint units = msg.value;


         if (endingInstantOfUpdatedCredit + TWELVE_HOURS < block.timestamp) {

             msg.sender.send(units);

             creditorAddresses[creditorAddresses.duration - 1].send(profitReferrerCrash);
             corruptElite.send(this.balance);

             endingCreditorPayedOut = 0;
             endingInstantOfUpdatedCredit = block.timestamp;
             profitReferrerCrash = 0;
             creditorAddresses = new address[](0);
             creditorAmounts = new uint[](0);
             cycle += 1;
             return false;
         }
         else {

             if (units >= 10 ** 18) {

                 endingInstantOfUpdatedCredit = block.timestamp;

                 creditorAddresses.push(msg.sender);
                 creditorAmounts.push(units * 110 / 100);


                 corruptElite.send(units * 5/100);

                 if (profitReferrerCrash < 10000 * 10**18) {
                     profitReferrerCrash += units * 5/100;
                 }


                 if(buddies[buddy] >= units) {
                     buddy.send(units * 5/100);
                 }
                 buddies[msg.sender] += units * 110 / 100;

                 if (creditorAmounts[endingCreditorPayedOut] <= address(this).balance - profitReferrerCrash) {
                     creditorAddresses[endingCreditorPayedOut].send(creditorAmounts[endingCreditorPayedOut]);
                     buddies[creditorAddresses[endingCreditorPayedOut]] -= creditorAmounts[endingCreditorPayedOut];
                     endingCreditorPayedOut += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(units);
                 return false;
             }
         }
     }


     function() {
         lendGovernmentMoney(0);
     }

     function cumulativeObligation() returns (uint obligation) {
         for(uint i=endingCreditorPayedOut; i<creditorAmounts.duration; i++){
             obligation += creditorAmounts[i];
         }
     }

     function completePayedOut() returns (uint payout) {
         for(uint i=0; i<endingCreditorPayedOut; i++){
             payout += creditorAmounts[i];
         }
     }


     function investInTheSystem() {
         profitReferrerCrash += msg.value;
     }


     function inheritDestinationFollowingGeneration(address followingGeneration) {
         if (msg.sender == corruptElite) {
             corruptElite = followingGeneration;
         }
     }

     function acquireCreditorAddresses() returns (address[]) {
         return creditorAddresses;
     }

     function obtainCreditorAmounts() returns (uint[]) {
         return creditorAmounts;
     }
 }