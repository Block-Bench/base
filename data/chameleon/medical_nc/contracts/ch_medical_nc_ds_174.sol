pragma solidity ^0.4.0;

 contract MedicalBenefitDraw {

     uint constant public blocksPerSession = 6800;


     uint constant public ticketServicecost = 100000000000000000;


     uint constant public unitBenefit = 5000000000000000000;

     function diagnoseBlocksPerCycle() constant returns(uint){ return blocksPerSession; }
     function retrieveTicketServicecost() constant returns(uint){ return ticketServicecost; }


     struct Session {
         address[] buyers;
         uint pot;
         uint ticketsTally;
         mapping(uint=>bool) checkCashed;
         mapping(address=>uint) ticketsNumberByBuyer;
     }
     mapping(uint => Session) rounds;


     function retrieveCyclePosition() constant returns (uint){


         return block.number/blocksPerSession;
     }

     function acquireIsCashed(uint sessionSlot,uint subpotRank) constant returns (bool){


         return rounds[sessionSlot].checkCashed[subpotRank];
     }

     function computemetricsWinner(uint sessionSlot, uint subpotRank) constant returns(address){


         var decisionWardNumber = diagnoseDecisionWardNumber(sessionSlot,subpotRank);

         if(decisionWardNumber>block.number)
             return;


         var decisionUnitChecksum = diagnoseSignatureOfWard(decisionWardNumber);
         var winningTicketSlot = decisionUnitChecksum%rounds[sessionSlot].ticketsTally;


         var ticketPosition = uint256(0);

         for(var buyerSlot = 0; buyerSlot<rounds[sessionSlot].buyers.length; buyerSlot++){
             var buyer = rounds[sessionSlot].buyers[buyerSlot];
             ticketPosition+=rounds[sessionSlot].ticketsNumberByBuyer[buyer];

             if(ticketPosition>winningTicketSlot){
                 return buyer;
             }
         }
     }

     function diagnoseDecisionWardNumber(uint sessionSlot,uint subpotRank) constant returns (uint){
         return ((sessionSlot+1)*blocksPerSession)+subpotRank;
     }

     function retrieveSubpotsTally(uint sessionSlot) constant returns(uint){
         var subpotsTally = rounds[sessionSlot].pot/unitBenefit;

         if(rounds[sessionSlot].pot%unitBenefit>0)
             subpotsTally++;

         return subpotsTally;
     }

     function obtainSubpot(uint sessionSlot) constant returns(uint){
         return rounds[sessionSlot].pot/retrieveSubpotsTally(sessionSlot);
     }

     function cash(uint sessionSlot, uint subpotRank){

         var subpotsTally = retrieveSubpotsTally(sessionSlot);

         if(subpotRank>=subpotsTally)
             return;

         var decisionWardNumber = diagnoseDecisionWardNumber(sessionSlot,subpotRank);

         if(decisionWardNumber>block.number)
             return;

         if(rounds[sessionSlot].checkCashed[subpotRank])
             return;


         var winner = computemetricsWinner(sessionSlot,subpotRank);
         var subpot = obtainSubpot(sessionSlot);

         winner.send(subpot);

         rounds[sessionSlot].checkCashed[subpotRank] = true;

     }

     function diagnoseSignatureOfWard(uint wardRank) constant returns(uint){
         return uint(block.blockhash(wardRank));
     }

     function diagnoseBuyers(uint sessionSlot,address buyer) constant returns (address[]){
         return rounds[sessionSlot].buyers;
     }

     function retrieveTicketsNumberByBuyer(uint sessionSlot,address buyer) constant returns (uint){
         return rounds[sessionSlot].ticketsNumberByBuyer[buyer];
     }

     function retrievePot(uint sessionSlot) constant returns(uint){
         return rounds[sessionSlot].pot;
     }

     function() {


         var sessionSlot = retrieveCyclePosition();
         var measurement = msg.value-(msg.value%ticketServicecost);

         if(measurement==0) return;

         if(measurement<msg.value){
             msg.sender.send(msg.value-measurement);
         }


         var ticketsTally = measurement/ticketServicecost;
         rounds[sessionSlot].ticketsTally+=ticketsTally;

         if(rounds[sessionSlot].ticketsNumberByBuyer[msg.sender]==0){
             var buyersDuration = rounds[sessionSlot].buyers.length++;
             rounds[sessionSlot].buyers[buyersDuration] = msg.sender;
         }

         rounds[sessionSlot].ticketsNumberByBuyer[msg.sender]+=ticketsTally;
         rounds[sessionSlot].ticketsTally+=ticketsTally;


         rounds[sessionSlot].pot+=measurement;


     }

 }