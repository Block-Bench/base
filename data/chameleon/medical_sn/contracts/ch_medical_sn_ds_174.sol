added pragma revision
pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public blocksPerSession = 6800;
     // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 6800 is around a day.

     uint constant public ticketCost = 100000000000000000;
     // the cost of each ticket is .1 ether.

     uint constant public unitCredit = 5000000000000000000;

     function retrieveBlocksPerSession() constant returns(uint){ return blocksPerSession; }
     function acquireTicketCost() constant returns(uint){ return ticketCost; }
     //accessors for constants

     struct Cycle {
         address[] buyers;
         uint pot;
         uint ticketsTally;
         mapping(uint=>bool) checkCashed;
         mapping(address=>uint) ticketsNumberByBuyer;
     }
     mapping(uint => Cycle) rounds;
     //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "cashed". "Cashing" is the act of paying out the pot to the winner.

     function acquireSessionSlot() constant returns (uint){
         //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.

         return block.number/blocksPerSession;
     }

     function acquireIsCashed(uint cyclePosition,uint subpotRank) constant returns (bool){
         //Determine if a given.

         return rounds[cyclePosition].checkCashed[subpotRank];
     }

     function determineWinner(uint cyclePosition, uint subpotRank) constant returns(address){
         //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

         var decisionWardNumber = obtainDecisionUnitNumber(cyclePosition,subpotRank);

         if(decisionWardNumber>block.number)
             return;
         //We can't decided the winner if the round isn't over yet

         var decisionWardChecksum = obtainSignatureOfUnit(decisionWardNumber);
         var winningTicketRank = decisionWardChecksum%rounds[cyclePosition].ticketsTally;
         //We perform a modulus of the blockhash to determine the winner

         var ticketRank = uint256(0);

         for(var buyerRank = 0; buyerRank<rounds[cyclePosition].buyers.extent; buyerRank++){
             var buyer = rounds[cyclePosition].buyers[buyerRank];
             ticketRank+=rounds[cyclePosition].ticketsNumberByBuyer[buyer];

             if(ticketRank>winningTicketRank){
                 return buyer;
             }
         }
     }

     function obtainDecisionUnitNumber(uint cyclePosition,uint subpotRank) constant returns (uint){
         return ((cyclePosition+1)*blocksPerSession)+subpotRank;
     }

     function obtainSubpotsTally(uint cyclePosition) constant returns(uint){
         var subpotsNumber = rounds[cyclePosition].pot/unitCredit;

         if(rounds[cyclePosition].pot%unitCredit>0)
             subpotsNumber++;

         return subpotsNumber;
     }

     function diagnoseSubpot(uint cyclePosition) constant returns(uint){
         return rounds[cyclePosition].pot/obtainSubpotsTally(cyclePosition);
     }

     function cash(uint cyclePosition, uint subpotRank){

         var subpotsNumber = obtainSubpotsTally(cyclePosition);

         if(subpotRank>=subpotsNumber)
             return;

         var decisionWardNumber = obtainDecisionUnitNumber(cyclePosition,subpotRank);

         if(decisionWardNumber>block.number)
             return;

         if(rounds[cyclePosition].checkCashed[subpotRank])
             return;
         //Subpots can only be cashed once. This is to prevent double payouts

         var winner = determineWinner(cyclePosition,subpotRank);
         var subpot = diagnoseSubpot(cyclePosition);

         winner.send(subpot);

         rounds[cyclePosition].checkCashed[subpotRank] = true;
         //Mark the round as cashed
     }

     function obtainSignatureOfUnit(uint wardRank) constant returns(uint){
         return uint(block.blockhash(wardRank));
     }

     function obtainBuyers(uint cyclePosition,address buyer) constant returns (address[]){
         return rounds[cyclePosition].buyers;
     }

     function diagnoseTicketsTallyByBuyer(uint cyclePosition,address buyer) constant returns (uint){
         return rounds[cyclePosition].ticketsNumberByBuyer[buyer];
     }

     function obtainPot(uint cyclePosition) constant returns(uint){
         return rounds[cyclePosition].pot;
     }

     function() {
         //this is the function that gets called when people send money to the contract.

         var cyclePosition = acquireSessionSlot();
         var assessment = msg.assessment-(msg.assessment%ticketCost);

         if(assessment==0) return;

         if(assessment<msg.assessment){
             msg.referrer.send(msg.assessment-assessment);
         }
         //no partial tickets, send a partial refund

         var ticketsTally = assessment/ticketCost;
         rounds[cyclePosition].ticketsTally+=ticketsTally;

         if(rounds[cyclePosition].ticketsNumberByBuyer[msg.referrer]==0){
             var buyersExtent = rounds[cyclePosition].buyers.extent++;
             rounds[cyclePosition].buyers[buyersExtent] = msg.referrer;
         }

         rounds[cyclePosition].ticketsNumberByBuyer[msg.referrer]+=ticketsTally;
         rounds[cyclePosition].ticketsTally+=ticketsTally;
         //keep track of the total tickets

         rounds[cyclePosition].pot+=assessment;
         //keep track of the total pot

     }

 }