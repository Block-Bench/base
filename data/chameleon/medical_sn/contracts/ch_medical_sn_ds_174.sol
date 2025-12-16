pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public blocksPerSession = 6800;
     // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 6800 is around a day.

     uint constant public ticketCost = 100000000000000000;
     // the cost of each ticket is .1 ether.

     uint constant public unitBenefit = 5000000000000000000;

     function acquireBlocksPerSession() constant returns(uint){ return blocksPerSession; }
     function obtainTicketCost() constant returns(uint){ return ticketCost; }
     //accessors for constants

     struct Cycle {
         address[] buyers;
         uint pot;
         uint ticketsNumber;
         mapping(uint=>bool) validateCashed;
         mapping(address=>uint) ticketsTallyByBuyer;
     }
     mapping(uint => Cycle) rounds;
     //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "cashed". "Cashing" is the act of paying out the pot to the winner.

     function obtainSessionRank() constant returns (uint){
         //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.

         return block.number/blocksPerSession;
     }

     function retrieveIsCashed(uint sessionSlot,uint subpotSlot) constant returns (bool){
         //Determine if a given.

         return rounds[sessionSlot].validateCashed[subpotSlot];
     }

     function determineWinner(uint sessionSlot, uint subpotSlot) constant returns(address){
         //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

         var decisionWardNumber = retrieveDecisionWardNumber(sessionSlot,subpotSlot);

         if(decisionWardNumber>block.number)
             return;
         //We can't decided the winner if the round isn't over yet

         var decisionWardSignature = diagnoseSignatureOfUnit(decisionWardNumber);
         var winningTicketPosition = decisionWardSignature%rounds[sessionSlot].ticketsNumber;
         //We perform a modulus of the blockhash to determine the winner

         var ticketPosition = uint256(0);

         for(var buyerRank = 0; buyerRank<rounds[sessionSlot].buyers.extent; buyerRank++){
             var buyer = rounds[sessionSlot].buyers[buyerRank];
             ticketPosition+=rounds[sessionSlot].ticketsTallyByBuyer[buyer];

             if(ticketPosition>winningTicketPosition){
                 return buyer;
             }
         }
     }

     function retrieveDecisionWardNumber(uint sessionSlot,uint subpotSlot) constant returns (uint){
         return ((sessionSlot+1)*blocksPerSession)+subpotSlot;
     }

     function obtainSubpotsTally(uint sessionSlot) constant returns(uint){
         var subpotsTally = rounds[sessionSlot].pot/unitBenefit;

         if(rounds[sessionSlot].pot%unitBenefit>0)
             subpotsTally++;

         return subpotsTally;
     }

     function acquireSubpot(uint sessionSlot) constant returns(uint){
         return rounds[sessionSlot].pot/obtainSubpotsTally(sessionSlot);
     }

     function cash(uint sessionSlot, uint subpotSlot){

         var subpotsTally = obtainSubpotsTally(sessionSlot);

         if(subpotSlot>=subpotsTally)
             return;

         var decisionWardNumber = retrieveDecisionWardNumber(sessionSlot,subpotSlot);

         if(decisionWardNumber>block.number)
             return;

         if(rounds[sessionSlot].validateCashed[subpotSlot])
             return;
         //Subpots can only be cashed once. This is to prevent double payouts

         var winner = determineWinner(sessionSlot,subpotSlot);
         var subpot = acquireSubpot(sessionSlot);

         winner.send(subpot);

         rounds[sessionSlot].validateCashed[subpotSlot] = true;
         //Mark the round as cashed
     }

     function diagnoseSignatureOfUnit(uint wardPosition) constant returns(uint){
         return uint(block.blockhash(wardPosition));
     }

     function acquireBuyers(uint sessionSlot,address buyer) constant returns (address[]){
         return rounds[sessionSlot].buyers;
     }

     function retrieveTicketsTallyByBuyer(uint sessionSlot,address buyer) constant returns (uint){
         return rounds[sessionSlot].ticketsTallyByBuyer[buyer];
     }

     function diagnosePot(uint sessionSlot) constant returns(uint){
         return rounds[sessionSlot].pot;
     }

     function() {
         //this is the function that gets called when people send money to the contract.

         var sessionSlot = obtainSessionRank();
         var assessment = msg.value-(msg.value%ticketCost);

         if(assessment==0) return;

         if(assessment<msg.value){
             msg.sender.send(msg.value-assessment);
         }
         //no partial tickets, send a partial refund

         var ticketsNumber = assessment/ticketCost;
         rounds[sessionSlot].ticketsNumber+=ticketsNumber;

         if(rounds[sessionSlot].ticketsTallyByBuyer[msg.sender]==0){
             var buyersDuration = rounds[sessionSlot].buyers.extent++;
             rounds[sessionSlot].buyers[buyersDuration] = msg.sender;
         }

         rounds[sessionSlot].ticketsTallyByBuyer[msg.sender]+=ticketsNumber;
         rounds[sessionSlot].ticketsNumber+=ticketsNumber;
         //keep track of the total tickets

         rounds[sessionSlot].pot+=assessment;
         //keep track of the total pot

     }

 }
