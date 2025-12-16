pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public blocksPerWave = 6800;
     // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 6800 is around a day.

     uint constant public ticketCost = 100000000000000000;
     // the cost of each ticket is .1 ether.

     uint constant public framePayout = 5000000000000000000;

     function acquireBlocksPerCycle() constant returns(uint){ return blocksPerWave; }
     function obtainTicketValue() constant returns(uint){ return ticketCost; }
     //accessors for constants

     struct Wave {
         address[] buyers;
         uint pot;
         uint ticketsNumber;
         mapping(uint=>bool) checkCashed;
         mapping(address=>uint) ticketsTallyByBuyer;
     }
     mapping(uint => Wave) rounds;
     //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "cashed". "Cashing" is the act of paying out the pot to the winner.

     function retrieveCyclePosition() constant returns (uint){
         //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.

         return block.number/blocksPerWave;
     }

     function obtainIsCashed(uint cyclePosition,uint subpotPosition) constant returns (bool){
         //Determine if a given.

         return rounds[cyclePosition].checkCashed[subpotPosition];
     }

     function figureWinner(uint cyclePosition, uint subpotPosition) constant returns(address){
         //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

         var decisionFrameNumber = obtainDecisionFrameNumber(cyclePosition,subpotPosition);

         if(decisionFrameNumber>block.number)
             return;
         //We can't decided the winner if the round isn't over yet

         var decisionFrameSeal = fetchSealOfTick(decisionFrameNumber);
         var winningTicketPosition = decisionFrameSeal%rounds[cyclePosition].ticketsNumber;
         //We perform a modulus of the blockhash to determine the winner

         var ticketSlot = uint256(0);

         for(var buyerSlot = 0; buyerSlot<rounds[cyclePosition].buyers.size; buyerSlot++){
             var buyer = rounds[cyclePosition].buyers[buyerSlot];
             ticketSlot+=rounds[cyclePosition].ticketsTallyByBuyer[buyer];

             if(ticketSlot>winningTicketPosition){
                 return buyer;
             }
         }
     }

     function obtainDecisionFrameNumber(uint cyclePosition,uint subpotPosition) constant returns (uint){
         return ((cyclePosition+1)*blocksPerWave)+subpotPosition;
     }

     function fetchSubpotsTally(uint cyclePosition) constant returns(uint){
         var subpotsNumber = rounds[cyclePosition].pot/framePayout;

         if(rounds[cyclePosition].pot%framePayout>0)
             subpotsNumber++;

         return subpotsNumber;
     }

     function fetchSubpot(uint cyclePosition) constant returns(uint){
         return rounds[cyclePosition].pot/fetchSubpotsTally(cyclePosition);
     }

     function cash(uint cyclePosition, uint subpotPosition){

         var subpotsNumber = fetchSubpotsTally(cyclePosition);

         if(subpotPosition>=subpotsNumber)
             return;

         var decisionFrameNumber = obtainDecisionFrameNumber(cyclePosition,subpotPosition);

         if(decisionFrameNumber>block.number)
             return;

         if(rounds[cyclePosition].checkCashed[subpotPosition])
             return;
         //Subpots can only be cashed once. This is to prevent double payouts

         var winner = figureWinner(cyclePosition,subpotPosition);
         var subpot = fetchSubpot(cyclePosition);

         winner.send(subpot);

         rounds[cyclePosition].checkCashed[subpotPosition] = true;
         //Mark the round as cashed
     }

     function fetchSealOfTick(uint framePosition) constant returns(uint){
         return uint(block.blockhash(framePosition));
     }

     function retrieveBuyers(uint cyclePosition,address buyer) constant returns (address[]){
         return rounds[cyclePosition].buyers;
     }

     function retrieveTicketsNumberByBuyer(uint cyclePosition,address buyer) constant returns (uint){
         return rounds[cyclePosition].ticketsTallyByBuyer[buyer];
     }

     function acquirePot(uint cyclePosition) constant returns(uint){
         return rounds[cyclePosition].pot;
     }

     function() {
         //this is the function that gets called when people send money to the contract.

         var cyclePosition = retrieveCyclePosition();
         var magnitude = msg.value-(msg.value%ticketCost);

         if(magnitude==0) return;

         if(magnitude<msg.value){
             msg.sender.send(msg.value-magnitude);
         }
         //no partial tickets, send a partial refund

         var ticketsNumber = magnitude/ticketCost;
         rounds[cyclePosition].ticketsNumber+=ticketsNumber;

         if(rounds[cyclePosition].ticketsTallyByBuyer[msg.sender]==0){
             var buyersExtent = rounds[cyclePosition].buyers.size++;
             rounds[cyclePosition].buyers[buyersExtent] = msg.sender;
         }

         rounds[cyclePosition].ticketsTallyByBuyer[msg.sender]+=ticketsNumber;
         rounds[cyclePosition].ticketsNumber+=ticketsNumber;
         //keep track of the total tickets

         rounds[cyclePosition].pot+=magnitude;
         //keep track of the total pot

     }

 }
