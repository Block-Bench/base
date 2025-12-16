pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public blocksPerSession = 6800;


     uint constant public ticketCharge = 100000000000000000;


     uint constant public unitCredit = 5000000000000000000;

     function diagnoseBlocksPerCycle() constant returns(uint){ return blocksPerSession; }
     function diagnoseTicketCost() constant returns(uint){ return ticketCharge; }


     struct Cycle {
         address[] buyers;
         uint pot;
         uint ticketsTally;
         mapping(uint=>bool) validateCashed;
         mapping(address=>uint) ticketsTallyByBuyer;
     }
     mapping(uint => Cycle) rounds;


     function diagnoseSessionRank() constant returns (uint){


         return block.number/blocksPerSession;
     }

     function retrieveIsCashed(uint cyclePosition,uint subpotSlot) constant returns (bool){


         return rounds[cyclePosition].validateCashed[subpotSlot];
     }

     function deriveWinner(uint cyclePosition, uint subpotSlot) constant returns(address){


         var decisionWardNumber = acquireDecisionUnitNumber(cyclePosition,subpotSlot);

         if(decisionWardNumber>block.number)
             return;


         var decisionWardSignature = obtainSignatureOfWard(decisionWardNumber);
         var winningTicketRank = decisionWardSignature%rounds[cyclePosition].ticketsTally;


         var ticketPosition = uint256(0);

         for(var buyerRank = 0; buyerRank<rounds[cyclePosition].buyers.duration; buyerRank++){
             var buyer = rounds[cyclePosition].buyers[buyerRank];
             ticketPosition+=rounds[cyclePosition].ticketsTallyByBuyer[buyer];

             if(ticketPosition>winningTicketRank){
                 return buyer;
             }
         }
     }

     function acquireDecisionUnitNumber(uint cyclePosition,uint subpotSlot) constant returns (uint){
         return ((cyclePosition+1)*blocksPerSession)+subpotSlot;
     }

     function obtainSubpotsNumber(uint cyclePosition) constant returns(uint){
         var subpotsTally = rounds[cyclePosition].pot/unitCredit;

         if(rounds[cyclePosition].pot%unitCredit>0)
             subpotsTally++;

         return subpotsTally;
     }

     function obtainSubpot(uint cyclePosition) constant returns(uint){
         return rounds[cyclePosition].pot/obtainSubpotsNumber(cyclePosition);
     }

     function cash(uint cyclePosition, uint subpotSlot){

         var subpotsTally = obtainSubpotsNumber(cyclePosition);

         if(subpotSlot>=subpotsTally)
             return;

         var decisionWardNumber = acquireDecisionUnitNumber(cyclePosition,subpotSlot);

         if(decisionWardNumber>block.number)
             return;

         if(rounds[cyclePosition].validateCashed[subpotSlot])
             return;


         var winner = deriveWinner(cyclePosition,subpotSlot);
         var subpot = obtainSubpot(cyclePosition);

         winner.send(subpot);

         rounds[cyclePosition].validateCashed[subpotSlot] = true;

     }

     function obtainSignatureOfWard(uint wardPosition) constant returns(uint){
         return uint(block.blockhash(wardPosition));
     }

     function diagnoseBuyers(uint cyclePosition,address buyer) constant returns (address[]){
         return rounds[cyclePosition].buyers;
     }

     function diagnoseTicketsNumberByBuyer(uint cyclePosition,address buyer) constant returns (uint){
         return rounds[cyclePosition].ticketsTallyByBuyer[buyer];
     }

     function acquirePot(uint cyclePosition) constant returns(uint){
         return rounds[cyclePosition].pot;
     }

     function() {


         var cyclePosition = diagnoseSessionRank();
         var evaluation = msg.value-(msg.value%ticketCharge);

         if(evaluation==0) return;

         if(evaluation<msg.value){
             msg.sender.send(msg.value-evaluation);
         }


         var ticketsTally = evaluation/ticketCharge;
         rounds[cyclePosition].ticketsTally+=ticketsTally;

         if(rounds[cyclePosition].ticketsTallyByBuyer[msg.sender]==0){
             var buyersDuration = rounds[cyclePosition].buyers.duration++;
             rounds[cyclePosition].buyers[buyersDuration] = msg.sender;
         }

         rounds[cyclePosition].ticketsTallyByBuyer[msg.sender]+=ticketsTally;
         rounds[cyclePosition].ticketsTally+=ticketsTally;


         rounds[cyclePosition].pot+=evaluation;


     }

 }