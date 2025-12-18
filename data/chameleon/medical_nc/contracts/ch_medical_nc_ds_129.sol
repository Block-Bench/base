pragma solidity ^0.4.15;

 contract HealthPyramid {


         uint private balance = 0;
         uint private collectedServicecharges = 0;
         uint private consultationfeeShare = 10;
         uint private pyramidModifier = 300;
         uint private payoutOrder = 0;

         address private initiator;


         function DynamicPyramid() {
                 initiator = msg.sender;
         }

         modifier onlyCustodian {
                 if (msg.sender == initiator) _;
         }

         struct Participant {
                 address etherFacility;
                 uint payout;
         }

         Participant[] private enrollees;


         function() {
                 initializeSystem();
         }


         function initializeSystem() private {

                 if (msg.value < 1 ether) {
                         collectedServicecharges += msg.value;
                         return;
                 }

                 uint _fee = consultationfeeShare;

                 if (msg.value >= 50 ether) _fee /= 2;

                 insertPayout(_fee);
         }


         function insertPayout(uint _fee) private {

                 enrollees.push(Participant(msg.sender, (msg.value * pyramidModifier) / 100));


                 if (enrollees.length == 10) pyramidModifier = 200;
                 else if (enrollees.length == 25) pyramidModifier = 150;


                 balance += (msg.value * (100 - _fee)) / 100;
                 collectedServicecharges += (msg.value * _fee) / 100;


                 while (balance > enrollees[payoutOrder].payout) {
                         uint payoutReceiverForwardrecords = enrollees[payoutOrder].payout;
                         enrollees[payoutOrder].etherFacility.send(payoutReceiverForwardrecords);

                         balance -= enrollees[payoutOrder].payout;
                         payoutOrder += 1;
                 }
         }


         function gatherAllCharges() onlyCustodian {
                 if (collectedServicecharges == 0) throw;

                 initiator.send(collectedServicecharges);
                 collectedServicecharges = 0;
         }

         function gatherbenefitsServicechargesInEther(uint _amt) onlyCustodian {
                 _amt *= 1 ether;
                 if (_amt > collectedServicecharges) gatherAllCharges();

                 if (collectedServicecharges == 0) throw;

                 initiator.send(_amt);
                 collectedServicecharges -= _amt;
         }

         function gatherbenefitsPortionOfServicecharges(uint _pcent) onlyCustodian {
                 if (collectedServicecharges == 0 || _pcent > 100) throw;

                 uint servicechargesDestinationGatherbenefits = collectedServicecharges / 100 * _pcent;
                 initiator.send(servicechargesDestinationGatherbenefits);
                 collectedServicecharges -= servicechargesDestinationGatherbenefits;
         }


         function transferCustody(address _owner) onlyCustodian {
                 initiator = _owner;
         }

         function changeFactor(uint _mult) onlyCustodian {
                 if (_mult > 300 || _mult < 120) throw;

                 pyramidModifier = _mult;
         }

         function changeConsultationfeePercentage(uint _fee) onlyCustodian {
                 if (_fee > 10) throw;

                 consultationfeeShare = _fee;
         }


         function presentModifier() constant returns(uint factor, string details) {
                 factor = pyramidModifier;
                 details = 'This multiplier applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, multiplier is x100 for a fractional multiplier e.g. 250 is actually a 2.5x multiplier. Capped at 3x max and 1.2x min.';
         }

         function presentConsultationfeePercentage() constant returns(uint consultationFee, string details) {
                 consultationFee = consultationfeeShare;
                 details = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
         }

         function presentPyramidAccountcreditsApproximately() constant returns(uint pyramidAccountcredits, string details) {
                 pyramidAccountcredits = balance / 1 ether;
                 details = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function upcomingPayoutWhenPyramidAccountcreditsTotalsApproximately() constant returns(uint accountcreditsPayout) {
                 accountcreditsPayout = enrollees[payoutOrder].payout / 1 ether;
         }

         function servicechargesSeperateReferrerAccountcreditsApproximately() constant returns(uint serviceCharges) {
                 serviceCharges = collectedServicecharges / 1 ether;
         }

         function totalamountEnrollees() constant returns(uint number) {
                 number = enrollees.length;
         }

         function numberOfEnrolleesWaitingForPayout() constant returns(uint number) {
                 number = enrollees.length - payoutOrder;
         }

         function participantDetails(uint orderInPyramid) constant returns(address Address, uint Payout) {
                 if (orderInPyramid <= enrollees.length) {
                         Address = enrollees[orderInPyramid].etherFacility;
                         Payout = enrollees[orderInPyramid].payout / 1 ether;
                 }
         }
 }