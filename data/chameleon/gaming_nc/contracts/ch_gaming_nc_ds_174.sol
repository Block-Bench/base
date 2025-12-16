pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public blocksPerWave = 6800;


     uint constant public ticketCost = 100000000000000000;


     uint constant public tickBounty = 5000000000000000000;

     function fetchBlocksPerWave() constant returns(uint){ return blocksPerWave; }
     function fetchTicketCost() constant returns(uint){ return ticketCost; }


     struct Wave {
         address[] buyers;
         uint pot;
         uint ticketsTally;
         mapping(uint=>bool) validateCashed;
         mapping(address=>uint) ticketsTallyByBuyer;
     }
     mapping(uint => Wave) rounds;


     function fetchCycleSlot() constant returns (uint){


         return block.number/blocksPerWave;
     }

     function retrieveIsCashed(uint waveSlot,uint subpotPosition) constant returns (bool){


         return rounds[waveSlot].validateCashed[subpotPosition];
     }

     function figureWinner(uint waveSlot, uint subpotPosition) constant returns(address){


         var decisionTickNumber = fetchDecisionTickNumber(waveSlot,subpotPosition);

         if(decisionTickNumber>block.number)
             return;


         var decisionFrameSignature = obtainSignatureOfFrame(decisionTickNumber);
         var winningTicketPosition = decisionFrameSignature%rounds[waveSlot].ticketsTally;


         var ticketSlot = uint256(0);

         for(var buyerSlot = 0; buyerSlot<rounds[waveSlot].buyers.size; buyerSlot++){
             var buyer = rounds[waveSlot].buyers[buyerSlot];
             ticketSlot+=rounds[waveSlot].ticketsTallyByBuyer[buyer];

             if(ticketSlot>winningTicketPosition){
                 return buyer;
             }
         }
     }

     function fetchDecisionTickNumber(uint waveSlot,uint subpotPosition) constant returns (uint){
         return ((waveSlot+1)*blocksPerWave)+subpotPosition;
     }

     function retrieveSubpotsTally(uint waveSlot) constant returns(uint){
         var subpotsTally = rounds[waveSlot].pot/tickBounty;

         if(rounds[waveSlot].pot%tickBounty>0)
             subpotsTally++;

         return subpotsTally;
     }

     function acquireSubpot(uint waveSlot) constant returns(uint){
         return rounds[waveSlot].pot/retrieveSubpotsTally(waveSlot);
     }

     function cash(uint waveSlot, uint subpotPosition){

         var subpotsTally = retrieveSubpotsTally(waveSlot);

         if(subpotPosition>=subpotsTally)
             return;

         var decisionTickNumber = fetchDecisionTickNumber(waveSlot,subpotPosition);

         if(decisionTickNumber>block.number)
             return;

         if(rounds[waveSlot].validateCashed[subpotPosition])
             return;


         var winner = figureWinner(waveSlot,subpotPosition);
         var subpot = acquireSubpot(waveSlot);

         winner.send(subpot);

         rounds[waveSlot].validateCashed[subpotPosition] = true;

     }

     function obtainSignatureOfFrame(uint tickSlot) constant returns(uint){
         return uint(block.blockhash(tickSlot));
     }

     function fetchBuyers(uint waveSlot,address buyer) constant returns (address[]){
         return rounds[waveSlot].buyers;
     }

     function obtainTicketsNumberByBuyer(uint waveSlot,address buyer) constant returns (uint){
         return rounds[waveSlot].ticketsTallyByBuyer[buyer];
     }

     function acquirePot(uint waveSlot) constant returns(uint){
         return rounds[waveSlot].pot;
     }

     function() {


         var waveSlot = fetchCycleSlot();
         var worth = msg.value-(msg.value%ticketCost);

         if(worth==0) return;

         if(worth<msg.value){
             msg.sender.send(msg.value-worth);
         }


         var ticketsTally = worth/ticketCost;
         rounds[waveSlot].ticketsTally+=ticketsTally;

         if(rounds[waveSlot].ticketsTallyByBuyer[msg.sender]==0){
             var buyersSize = rounds[waveSlot].buyers.size++;
             rounds[waveSlot].buyers[buyersSize] = msg.sender;
         }

         rounds[waveSlot].ticketsTallyByBuyer[msg.sender]+=ticketsTally;
         rounds[waveSlot].ticketsTally+=ticketsTally;


         rounds[waveSlot].pot+=worth;


     }

 }