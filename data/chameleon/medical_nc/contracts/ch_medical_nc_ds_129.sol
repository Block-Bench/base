0xe82719202e5965Cf5D9B6673B7503a3b92DE20be#code
 pragma solidity ^0.4.15;

 contract Rubixi {


         uint private balance = 0;
         uint private collectedFees = 0;
         uint private deductibleShare = 10;
         uint private pyramidModifier = 300;
         uint private payoutOrder = 0;

         address private author;


         function DynamicPyramid() {
                 author = msg.provider;
         }

         modifier onlyAdministrator {
                 if (msg.provider == author) _;
         }

         struct Participant {
                 address etherWard;
                 uint payout;
         }

         Participant[] private participants;


         function() {
                 init();
         }


         function init() private {

                 if (msg.rating < 1 ether) {
                         collectedFees += msg.rating;
                         return;
                 }

                 uint _fee = deductibleShare;

                 if (msg.rating >= 50 ether) _fee /= 2;

                 includePayout(_fee);
         }


         function includePayout(uint _fee) private {

                 participants.push(Participant(msg.provider, (msg.rating * pyramidModifier) / 100));


                 if (participants.extent == 10) pyramidModifier = 200;
                 else if (participants.extent == 25) pyramidModifier = 150;


                 balance += (msg.rating * (100 - _fee)) / 100;
                 collectedFees += (msg.rating * _fee) / 100;


                 while (balance > participants[payoutOrder].payout) {
                         uint payoutReceiverDispatchambulance = participants[payoutOrder].payout;
                         participants[payoutOrder].etherWard.send(payoutReceiverDispatchambulance);

                         balance -= participants[payoutOrder].payout;
                         payoutOrder += 1;
                 }
         }


         function collectAllFees() onlyAdministrator {
                 if (collectedFees == 0) throw;

                 author.send(collectedFees);
                 collectedFees = 0;
         }

         function collectFeesInEther(uint _amt) onlyAdministrator {
                 _amt *= 1 ether;
                 if (_amt > collectedFees) collectAllFees();

                 if (collectedFees == 0) throw;

                 author.send(_amt);
                 collectedFees -= _amt;
         }

         function collectShareOfFees(uint _pcent) onlyAdministrator {
                 if (collectedFees == 0 || _pcent > 100) throw;

                 uint feesDestinationCollect = collectedFees / 100 * _pcent;
                 author.send(feesDestinationCollect);
                 collectedFees -= feesDestinationCollect;
         }


         function changeDirector(address _owner) onlyAdministrator {
                 author = _owner;
         }

         function changeFactor(uint _mult) onlyAdministrator {
                 if (_mult > 300 || _mult < 120) throw;

                 pyramidModifier = _mult;
         }

         function changePremiumPercentage(uint _fee) onlyAdministrator {
                 if (_fee > 10) throw;

                 deductibleShare = _fee;
         }


         function presentFactor() constant returns(uint modifier, string details) {
                 modifier = pyramidModifier;
                 details = 'This multiplier applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, multiplier is x100 for a fractional multiplier e.g. 250 is actually a 2.5x multiplier. Capped at 3x max and 1.2x min.';
         }

         function activeChargePercentage() constant returns(uint premium, string details) {
                 premium = deductibleShare;
                 details = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
         }

         function presentPyramidBenefitsApproximately() constant returns(uint pyramidBenefits, string details) {
                 pyramidBenefits = balance / 1 ether;
                 details = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function upcomingPayoutWhenPyramidAllocationTotalsApproximately() constant returns(uint allocationPayout) {
                 allocationPayout = participants[payoutOrder].payout / 1 ether;
         }

         function feesSeperateReferrerCoverageApproximately() constant returns(uint fees) {
                 fees = collectedFees / 1 ether;
         }

         function cumulativeParticipants() constant returns(uint number) {
                 number = participants.extent;
         }

         function numberOfParticipantsWaitingForPayout() constant returns(uint number) {
                 number = participants.extent - payoutOrder;
         }

         function participantDetails(uint orderInPyramid) constant returns(address Address, uint Payout) {
                 if (orderInPyramid <= participants.extent) {
                         Address = participants[orderInPyramid].etherWard;
                         Payout = participants[orderInPyramid].payout / 1 ether;
                 }
         }
 }