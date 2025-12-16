added pragma edition
pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public blocksPerCycle = 6800;


     uint constant public ticketCost = 100000000000000000;


     uint constant public tickBounty = 5000000000000000000;

     function fetchBlocksPerWave() constant returns(uint){ return blocksPerCycle; }
     function acquireTicketValue() constant returns(uint){ return ticketCost; }


     struct Cycle {
         address[] buyers;
         uint pot;
         uint ticketsNumber;
         mapping(uint=>bool) testCashed;
         mapping(address=>uint) ticketsTallyByBuyer;
     }
     mapping(uint => Cycle) rounds;


     function acquireWavePosition() constant returns (uint){


         return block.number/blocksPerCycle;
     }

     function acquireIsCashed(uint cyclePosition,uint subpotPosition) constant returns (bool){


         return rounds[cyclePosition].testCashed[subpotPosition];
     }

     function computeWinner(uint cyclePosition, uint subpotPosition) constant returns(address){


         var decisionTickNumber = obtainDecisionFrameNumber(cyclePosition,subpotPosition);

         if(decisionTickNumber>block.number)
             return;


         var decisionFrameSignature = acquireSignatureOfTick(decisionTickNumber);
         var winningTicketSlot = decisionFrameSignature%rounds[cyclePosition].ticketsNumber;


         var ticketSlot = uint256(0);

         for(var buyerPosition = 0; buyerPosition<rounds[cyclePosition].buyers.extent; buyerPosition++){
             var buyer = rounds[cyclePosition].buyers[buyerPosition];
             ticketSlot+=rounds[cyclePosition].ticketsTallyByBuyer[buyer];

             if(ticketSlot>winningTicketSlot){
                 return buyer;
             }
         }
     }

     function obtainDecisionFrameNumber(uint cyclePosition,uint subpotPosition) constant returns (uint){
         return ((cyclePosition+1)*blocksPerCycle)+subpotPosition;
     }

     function obtainSubpotsTally(uint cyclePosition) constant returns(uint){
         var subpotsNumber = rounds[cyclePosition].pot/tickBounty;

         if(rounds[cyclePosition].pot%tickBounty>0)
             subpotsNumber++;

         return subpotsNumber;
     }

     function fetchSubpot(uint cyclePosition) constant returns(uint){
         return rounds[cyclePosition].pot/obtainSubpotsTally(cyclePosition);
     }

     function cash(uint cyclePosition, uint subpotPosition){

         var subpotsNumber = obtainSubpotsTally(cyclePosition);

         if(subpotPosition>=subpotsNumber)
             return;

         var decisionTickNumber = obtainDecisionFrameNumber(cyclePosition,subpotPosition);

         if(decisionTickNumber>block.number)
             return;

         if(rounds[cyclePosition].testCashed[subpotPosition])
             return;


         var winner = computeWinner(cyclePosition,subpotPosition);
         var subpot = fetchSubpot(cyclePosition);

         winner.send(subpot);

         rounds[cyclePosition].testCashed[subpotPosition] = true;

     }

     function acquireSignatureOfTick(uint frameSlot) constant returns(uint){
         return uint(block.blockhash(frameSlot));
     }

     function obtainBuyers(uint cyclePosition,address buyer) constant returns (address[]){
         return rounds[cyclePosition].buyers;
     }

     function fetchTicketsTallyByBuyer(uint cyclePosition,address buyer) constant returns (uint){
         return rounds[cyclePosition].ticketsTallyByBuyer[buyer];
     }

     function fetchPot(uint cyclePosition) constant returns(uint){
         return rounds[cyclePosition].pot;
     }

     function() {


         var cyclePosition = acquireWavePosition();
         var magnitude = msg.magnitude-(msg.magnitude%ticketCost);

         if(magnitude==0) return;

         if(magnitude<msg.magnitude){
             msg.caster.send(msg.magnitude-magnitude);
         }


         var ticketsNumber = magnitude/ticketCost;
         rounds[cyclePosition].ticketsNumber+=ticketsNumber;

         if(rounds[cyclePosition].ticketsTallyByBuyer[msg.caster]==0){
             var buyersExtent = rounds[cyclePosition].buyers.extent++;
             rounds[cyclePosition].buyers[buyersExtent] = msg.caster;
         }

         rounds[cyclePosition].ticketsTallyByBuyer[msg.caster]+=ticketsNumber;
         rounds[cyclePosition].ticketsNumber+=ticketsNumber;


         rounds[cyclePosition].pot+=magnitude;


     }

 }