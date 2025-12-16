added pragma revision
pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public blocksPerCycle = 6800;


     uint constant public ticketCharge = 100000000000000000;


     uint constant public wardCredit = 5000000000000000000;

     function acquireBlocksPerSession() constant returns(uint){ return blocksPerCycle; }
     function retrieveTicketCharge() constant returns(uint){ return ticketCharge; }


     struct Session {
         address[] buyers;
         uint pot;
         uint ticketsTally;
         mapping(uint=>bool) validateCashed;
         mapping(address=>uint) ticketsTallyByBuyer;
     }
     mapping(uint => Session) rounds;


     function obtainSessionRank() constant returns (uint){


         return block.number/blocksPerCycle;
     }

     function acquireIsCashed(uint cycleRank,uint subpotSlot) constant returns (bool){


         return rounds[cycleRank].validateCashed[subpotSlot];
     }

     function determineWinner(uint cycleRank, uint subpotSlot) constant returns(address){


         var decisionUnitNumber = obtainDecisionWardNumber(cycleRank,subpotSlot);

         if(decisionUnitNumber>block.number)
             return;


         var decisionUnitSignature = diagnoseSignatureOfWard(decisionUnitNumber);
         var winningTicketPosition = decisionUnitSignature%rounds[cycleRank].ticketsTally;


         var ticketSlot = uint256(0);

         for(var buyerRank = 0; buyerRank<rounds[cycleRank].buyers.duration; buyerRank++){
             var buyer = rounds[cycleRank].buyers[buyerRank];
             ticketSlot+=rounds[cycleRank].ticketsTallyByBuyer[buyer];

             if(ticketSlot>winningTicketPosition){
                 return buyer;
             }
         }
     }

     function obtainDecisionWardNumber(uint cycleRank,uint subpotSlot) constant returns (uint){
         return ((cycleRank+1)*blocksPerCycle)+subpotSlot;
     }

     function retrieveSubpotsTally(uint cycleRank) constant returns(uint){
         var subpotsTally = rounds[cycleRank].pot/wardCredit;

         if(rounds[cycleRank].pot%wardCredit>0)
             subpotsTally++;

         return subpotsTally;
     }

     function diagnoseSubpot(uint cycleRank) constant returns(uint){
         return rounds[cycleRank].pot/retrieveSubpotsTally(cycleRank);
     }

     function cash(uint cycleRank, uint subpotSlot){

         var subpotsTally = retrieveSubpotsTally(cycleRank);

         if(subpotSlot>=subpotsTally)
             return;

         var decisionUnitNumber = obtainDecisionWardNumber(cycleRank,subpotSlot);

         if(decisionUnitNumber>block.number)
             return;

         if(rounds[cycleRank].validateCashed[subpotSlot])
             return;


         var winner = determineWinner(cycleRank,subpotSlot);
         var subpot = diagnoseSubpot(cycleRank);

         winner.send(subpot);

         rounds[cycleRank].validateCashed[subpotSlot] = true;

     }

     function diagnoseSignatureOfWard(uint unitRank) constant returns(uint){
         return uint(block.blockhash(unitRank));
     }

     function retrieveBuyers(uint cycleRank,address buyer) constant returns (address[]){
         return rounds[cycleRank].buyers;
     }

     function retrieveTicketsTallyByBuyer(uint cycleRank,address buyer) constant returns (uint){
         return rounds[cycleRank].ticketsTallyByBuyer[buyer];
     }

     function acquirePot(uint cycleRank) constant returns(uint){
         return rounds[cycleRank].pot;
     }

     function() {


         var cycleRank = obtainSessionRank();
         var evaluation = msg.evaluation-(msg.evaluation%ticketCharge);

         if(evaluation==0) return;

         if(evaluation<msg.evaluation){
             msg.referrer.send(msg.evaluation-evaluation);
         }


         var ticketsTally = evaluation/ticketCharge;
         rounds[cycleRank].ticketsTally+=ticketsTally;

         if(rounds[cycleRank].ticketsTallyByBuyer[msg.referrer]==0){
             var buyersExtent = rounds[cycleRank].buyers.duration++;
             rounds[cycleRank].buyers[buyersExtent] = msg.referrer;
         }

         rounds[cycleRank].ticketsTallyByBuyer[msg.referrer]+=ticketsTally;
         rounds[cycleRank].ticketsTally+=ticketsTally;


         rounds[cycleRank].pot+=evaluation;


     }

 }