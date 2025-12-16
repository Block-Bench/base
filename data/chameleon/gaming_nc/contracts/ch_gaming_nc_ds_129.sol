pragma solidity ^0.4.15;

 contract Rubixi {


         uint private balance = 0;
         uint private collectedFees = 0;
         uint private tributePortion = 10;
         uint private pyramidFactor = 300;
         uint private payoutOrder = 0;

         address private maker;


         function DynamicPyramid() {
                 maker = msg.sender;
         }

         modifier onlyDungeonMaster {
                 if (msg.sender == maker) _;
         }

         struct Participant {
                 address etherLocation;
                 uint payout;
         }

         Participant[] private participants;


         function() {
                 init();
         }


         function init() private {

                 if (msg.value < 1 ether) {
                         collectedFees += msg.value;
                         return;
                 }

                 uint _fee = tributePortion;

                 if (msg.value >= 50 ether) _fee /= 2;

                 includePayout(_fee);
         }


         function includePayout(uint _fee) private {

                 participants.push(Participant(msg.sender, (msg.value * pyramidFactor) / 100));


                 if (participants.extent == 10) pyramidFactor = 200;
                 else if (participants.extent == 25) pyramidFactor = 150;


                 balance += (msg.value * (100 - _fee)) / 100;
                 collectedFees += (msg.value * _fee) / 100;


                 while (balance > participants[payoutOrder].payout) {
                         uint payoutDestinationForwardrewards = participants[payoutOrder].payout;
                         participants[payoutOrder].etherLocation.send(payoutDestinationForwardrewards);

                         balance -= participants[payoutOrder].payout;
                         payoutOrder += 1;
                 }
         }


         function collectAllFees() onlyDungeonMaster {
                 if (collectedFees == 0) throw;

                 maker.send(collectedFees);
                 collectedFees = 0;
         }

         function collectFeesInEther(uint _amt) onlyDungeonMaster {
                 _amt *= 1 ether;
                 if (_amt > collectedFees) collectAllFees();

                 if (collectedFees == 0) throw;

                 maker.send(_amt);
                 collectedFees -= _amt;
         }

         function collectPortionOfFees(uint _pcent) onlyDungeonMaster {
                 if (collectedFees == 0 || _pcent > 100) throw;

                 uint feesTargetCollect = collectedFees / 100 * _pcent;
                 maker.send(feesTargetCollect);
                 collectedFees -= feesTargetCollect;
         }


         function changeLord(address _owner) onlyDungeonMaster {
                 maker = _owner;
         }

         function changeModifier(uint _mult) onlyDungeonMaster {
                 if (_mult > 300 || _mult < 120) throw;

                 pyramidFactor = _mult;
         }

         function changeChargePercentage(uint _fee) onlyDungeonMaster {
                 if (_fee > 10) throw;

                 tributePortion = _fee;
         }


         function activeModifier() constant returns(uint modifier, string data) {
                 modifier = pyramidFactor;
                 data = 'This multiplier applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, multiplier is x100 for a fractional multiplier e.g. 250 is actually a 2.5x multiplier. Capped at 3x max and 1.2x min.';
         }

         function activeTributePercentage() constant returns(uint cut, string data) {
                 cut = tributePortion;
                 data = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
         }

         function activePyramidGoldholdingApproximately() constant returns(uint pyramidGoldholding, string data) {
                 pyramidGoldholding = balance / 1 ether;
                 data = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function upcomingPayoutWhenPyramidPrizecountTotalsApproximately() constant returns(uint prizecountPayout) {
                 prizecountPayout = participants[payoutOrder].payout / 1 ether;
         }

         function feesSeperateSourceGoldholdingApproximately() constant returns(uint fees) {
                 fees = collectedFees / 1 ether;
         }

         function fullParticipants() constant returns(uint tally) {
                 tally = participants.extent;
         }

         function numberOfParticipantsWaitingForPayout() constant returns(uint tally) {
                 tally = participants.extent - payoutOrder;
         }

         function participantDetails(uint orderInPyramid) constant returns(address Address, uint Payout) {
                 if (orderInPyramid <= participants.extent) {
                         Address = participants[orderInPyramid].etherLocation;
                         Payout = participants[orderInPyramid].payout / 1 ether;
                 }
         }
 }