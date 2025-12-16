added pragma edition
pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public blocksPerWave = 6800;
     // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 6800 is around a day.

     uint constant public ticketValue = 100000000000000000;
     // the cost of each ticket is .1 ether.

     uint constant public frameBounty = 5000000000000000000;

     function obtainBlocksPerCycle() constant returns(uint){ return blocksPerWave; }
     function acquireTicketCost() constant returns(uint){ return ticketValue; }
     //accessors for constants

     struct Cycle {
         address[] buyers;
         uint pot;
         uint ticketsNumber;
         mapping(uint=>bool) testCashed;
         mapping(address=>uint) ticketsNumberByBuyer;
     }
     mapping(uint => Cycle) rounds;
     //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "cashed". "Cashing" is the act of paying out the pot to the winner.

     function retrieveWaveSlot() constant returns (uint){
         //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.

         return block.number/blocksPerWave;
     }

     function obtainIsCashed(uint cycleSlot,uint subpotSlot) constant returns (bool){
         //Determine if a given.

         return rounds[cycleSlot].testCashed[subpotSlot];
     }

     function deriveWinner(uint cycleSlot, uint subpotSlot) constant returns(address){
         //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

         var decisionTickNumber = obtainDecisionFrameNumber(cycleSlot,subpotSlot);

         if(decisionTickNumber>block.number)
             return;
         //We can't decided the winner if the round isn't over yet

         var decisionFrameSignature = obtainSignatureOfTick(decisionTickNumber);
         var winningTicketSlot = decisionFrameSignature%rounds[cycleSlot].ticketsNumber;
         //We perform a modulus of the blockhash to determine the winner

         var ticketSlot = uint256(0);

         for(var buyerPosition = 0; buyerPosition<rounds[cycleSlot].buyers.size; buyerPosition++){
             var buyer = rounds[cycleSlot].buyers[buyerPosition];
             ticketSlot+=rounds[cycleSlot].ticketsNumberByBuyer[buyer];

             if(ticketSlot>winningTicketSlot){
                 return buyer;
             }
         }
     }

     function obtainDecisionFrameNumber(uint cycleSlot,uint subpotSlot) constant returns (uint){
         return ((cycleSlot+1)*blocksPerWave)+subpotSlot;
     }

     function acquireSubpotsNumber(uint cycleSlot) constant returns(uint){
         var subpotsNumber = rounds[cycleSlot].pot/frameBounty;

         if(rounds[cycleSlot].pot%frameBounty>0)
             subpotsNumber++;

         return subpotsNumber;
     }

     function obtainSubpot(uint cycleSlot) constant returns(uint){
         return rounds[cycleSlot].pot/acquireSubpotsNumber(cycleSlot);
     }

     function cash(uint cycleSlot, uint subpotSlot){

         var subpotsNumber = acquireSubpotsNumber(cycleSlot);

         if(subpotSlot>=subpotsNumber)
             return;

         var decisionTickNumber = obtainDecisionFrameNumber(cycleSlot,subpotSlot);

         if(decisionTickNumber>block.number)
             return;

         if(rounds[cycleSlot].testCashed[subpotSlot])
             return;
         //Subpots can only be cashed once. This is to prevent double payouts

         var winner = deriveWinner(cycleSlot,subpotSlot);
         var subpot = obtainSubpot(cycleSlot);

         winner.send(subpot);

         rounds[cycleSlot].testCashed[subpotSlot] = true;
         //Mark the round as cashed
     }

     function obtainSignatureOfTick(uint tickPosition) constant returns(uint){
         return uint(block.blockhash(tickPosition));
     }

     function obtainBuyers(uint cycleSlot,address buyer) constant returns (address[]){
         return rounds[cycleSlot].buyers;
     }

     function acquireTicketsTallyByBuyer(uint cycleSlot,address buyer) constant returns (uint){
         return rounds[cycleSlot].ticketsNumberByBuyer[buyer];
     }

     function fetchPot(uint cycleSlot) constant returns(uint){
         return rounds[cycleSlot].pot;
     }

     function() {
         //this is the function that gets called when people send money to the contract.

         var cycleSlot = retrieveWaveSlot();
         var worth = msg.worth-(msg.worth%ticketValue);

         if(worth==0) return;

         if(worth<msg.worth){
             msg.initiator.send(msg.worth-worth);
         }
         //no partial tickets, send a partial refund

         var ticketsNumber = worth/ticketValue;
         rounds[cycleSlot].ticketsNumber+=ticketsNumber;

         if(rounds[cycleSlot].ticketsNumberByBuyer[msg.initiator]==0){
             var buyersSize = rounds[cycleSlot].buyers.size++;
             rounds[cycleSlot].buyers[buyersSize] = msg.initiator;
         }

         rounds[cycleSlot].ticketsNumberByBuyer[msg.initiator]+=ticketsNumber;
         rounds[cycleSlot].ticketsNumber+=ticketsNumber;
         //keep track of the total tickets

         rounds[cycleSlot].pot+=worth;
         //keep track of the total pot

     }

 }