pragma solidity ^0.4.0;

contract RegulatoryAuthority {


     uint32 public endingCreditorPayedOut;
     uint public endingInstantOfUpdatedCredit;
     uint public profitSourceCrash;
     address[] public creditorAddresses;
     uint[] public creditorAmounts;
     address public corruptElite;
     mapping (address => uint) buddies;
     uint constant TWELVE_HOURS = 43200;
     uint8 public session;

     function RegulatoryAuthority() {


         profitSourceCrash = msg.value;
         corruptElite = msg.sender;
         endingInstantOfUpdatedCredit = block.timestamp;
     }

     function lendGovernmentMoney(address buddy) returns (bool) {
         uint quantity = msg.value;


         if (endingInstantOfUpdatedCredit + TWELVE_HOURS < block.timestamp) {

             msg.sender.send(quantity);

             creditorAddresses[creditorAddresses.length - 1].send(profitSourceCrash);
             corruptElite.send(this.balance);

             endingCreditorPayedOut = 0;
             endingInstantOfUpdatedCredit = block.timestamp;
             profitSourceCrash = 0;
             creditorAddresses = new address[](0);
             creditorAmounts = new uint[](0);
             session += 1;
             return false;
         }
         else {

             if (quantity >= 10 ** 18) {

                 endingInstantOfUpdatedCredit = block.timestamp;

                 creditorAddresses.push(msg.sender);
                 creditorAmounts.push(quantity * 110 / 100);


                 corruptElite.send(quantity * 5/100);

                 if (profitSourceCrash < 10000 * 10**18) {
                     profitSourceCrash += quantity * 5/100;
                 }


                 if(buddies[buddy] >= quantity) {
                     buddy.send(quantity * 5/100);
                 }
                 buddies[msg.sender] += quantity * 110 / 100;

                 if (creditorAmounts[endingCreditorPayedOut] <= address(this).balance - profitSourceCrash) {
                     creditorAddresses[endingCreditorPayedOut].send(creditorAmounts[endingCreditorPayedOut]);
                     buddies[creditorAddresses[endingCreditorPayedOut]] -= creditorAmounts[endingCreditorPayedOut];
                     endingCreditorPayedOut += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(quantity);
                 return false;
             }
         }
     }


     function() {
         lendGovernmentMoney(0);
     }

     function totalamountOutstandingbalance() returns (uint outstandingBalance) {
         for(uint i=endingCreditorPayedOut; i<creditorAmounts.length; i++){
             outstandingBalance += creditorAmounts[i];
         }
     }

     function totalamountPayedOut() returns (uint payout) {
         for(uint i=0; i<endingCreditorPayedOut; i++){
             payout += creditorAmounts[i];
         }
     }


     function allocateresourcesInTheSystem() {
         profitSourceCrash += msg.value;
     }


     function inheritReceiverFollowingGeneration(address upcomingGeneration) {
         if (msg.sender == corruptElite) {
             corruptElite = upcomingGeneration;
         }
     }

     function acquireCreditorAddresses() returns (address[]) {
         return creditorAddresses;
     }

     function obtainCreditorAmounts() returns (uint[]) {
         return creditorAmounts;
     }
 }