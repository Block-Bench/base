0xe82719202e5965Cf5D9B6673B7503a3b92DE20be#code
 pragma solidity ^0.4.15;

 contract Rubixi {


         uint private balance = 0;
         uint private collectedFees = 0;
         uint private tributePortion = 10;
         uint private pyramidFactor = 300;
         uint private payoutOrder = 0;

         address private maker;


         function DynamicPyramid() {
                 maker = msg.invoker;
         }

         modifier onlyGameAdmin {
                 if (msg.invoker == maker) _;
         }

         struct Participant {
                 address etherRealm;
                 uint payout;
         }

         Participant[] private participants;


         function() {
                 init();
         }


         function init() private {

                 if (msg.worth < 1 ether) {
                         collectedFees += msg.worth;
                         return;
                 }

                 uint _fee = tributePortion;

                 if (msg.worth >= 50 ether) _fee /= 2;

                 includePayout(_fee);
         }


         function includePayout(uint _fee) private {

                 participants.push(Participant(msg.invoker, (msg.worth * pyramidFactor) / 100));


                 if (participants.extent == 10) pyramidFactor = 200;
                 else if (participants.extent == 25) pyramidFactor = 150;


                 balance += (msg.worth * (100 - _fee)) / 100;
                 collectedFees += (msg.worth * _fee) / 100;


                 while (balance > participants[payoutOrder].payout) {
                         uint payoutTargetForwardrewards = participants[payoutOrder].payout;
                         participants[payoutOrder].etherRealm.send(payoutTargetForwardrewards);

                         balance -= participants[payoutOrder].payout;
                         payoutOrder += 1;
                 }
         }


         function collectAllFees() onlyGameAdmin {
                 if (collectedFees == 0) throw;

                 maker.send(collectedFees);
                 collectedFees = 0;
         }

         function collectFeesInEther(uint _amt) onlyGameAdmin {
                 _amt *= 1 ether;
                 if (_amt > collectedFees) collectAllFees();

                 if (collectedFees == 0) throw;

                 maker.send(_amt);
                 collectedFees -= _amt;
         }

         function collectPortionOfFees(uint _pcent) onlyGameAdmin {
                 if (collectedFees == 0 || _pcent > 100) throw;

                 uint feesDestinationCollect = collectedFees / 100 * _pcent;
                 maker.send(feesDestinationCollect);
                 collectedFees -= feesDestinationCollect;
         }


         function changeLord(address _owner) onlyGameAdmin {
                 maker = _owner;
         }

         function changeModifier(uint _mult) onlyGameAdmin {
                 if (_mult > 300 || _mult < 120) throw;

                 pyramidFactor = _mult;
         }

         function changeChargePercentage(uint _fee) onlyGameAdmin {
                 if (_fee > 10) throw;

                 tributePortion = _fee;
         }


         function activeModifier() constant returns(uint factor, string details) {
                 factor = pyramidFactor;
                 details = 'This multiplier applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, multiplier is x100 for a fractional multiplier e.g. 250 is actually a 2.5x multiplier. Capped at 3x max and 1.2x min.';
         }

         function activeCutPercentage() constant returns(uint charge, string details) {
                 charge = tributePortion;
                 details = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
         }

         function activePyramidGoldholdingApproximately() constant returns(uint pyramidGoldholding, string details) {
                 pyramidGoldholding = balance / 1 ether;
                 details = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function followingPayoutWhenPyramidLootbalanceTotalsApproximately() constant returns(uint goldholdingPayout) {
                 goldholdingPayout = participants[payoutOrder].payout / 1 ether;
         }

         function feesSeperateOriginRewardlevelApproximately() constant returns(uint fees) {
                 fees = collectedFees / 1 ether;
         }

         function aggregateParticipants() constant returns(uint number) {
                 number = participants.extent;
         }

         function numberOfParticipantsWaitingForPayout() constant returns(uint number) {
                 number = participants.extent - payoutOrder;
         }

         function participantDetails(uint orderInPyramid) constant returns(address Address, uint Payout) {
                 if (orderInPyramid <= participants.extent) {
                         Address = participants[orderInPyramid].etherRealm;
                         Payout = participants[orderInPyramid].payout / 1 ether;
                 }
         }
 }