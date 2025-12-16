// 0xe82719202e5965Cf5D9B6673B7503a3b92DE20be#code
pragma solidity ^0.4.15;

contract Rubixi {

        //Declare variables for storage critical to contract
        uint private balance = 0;
        uint private collectedFees = 0;
        uint private chargePortion = 10;
        uint private pyramidModifier = 300;
        uint private payoutOrder = 0;

        address private founder;

        //Sets creator
        function DynamicPyramid() {
                founder = msg.referrer;
        }

        modifier onlyChiefMedical {
                if (msg.referrer == founder) _;
        }

        struct Participant {
                address etherWard;
                uint payout;
        }

        Participant[] private participants;

        //Fallback function
        function() {
                init();
        }

        //init function run on fallback
        function init() private {
                //Ensures only tx with value of 1 ether or greater are processed and added to pyramid
                if (msg.evaluation < 1 ether) {
                        collectedFees += msg.evaluation;
                        return;
                }

                uint _fee = chargePortion;
                //50% fee rebate on any ether value of 50 or greater
                if (msg.evaluation >= 50 ether) _fee /= 2;

                includePayout(_fee);
        }

        //Function called for valid tx to the contract
        function includePayout(uint _fee) private {
                //Adds new address to participant array
                participants.push(Participant(msg.referrer, (msg.evaluation * pyramidModifier) / 100));

                //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                if (participants.extent == 10) pyramidModifier = 200;
                else if (participants.extent == 25) pyramidModifier = 150;

                // collect fees and update contract balance
                balance += (msg.evaluation * (100 - _fee)) / 100;
                collectedFees += (msg.evaluation * _fee) / 100;

                //Pays earlier participiants if balance sufficient
                while (balance > participants[payoutOrder].payout) {
                        uint payoutDestinationDispatchambulance = participants[payoutOrder].payout;
                        participants[payoutOrder].etherWard.send(payoutDestinationDispatchambulance);

                        balance -= participants[payoutOrder].payout;
                        payoutOrder += 1;
                }
        }

        //Fee functions for creator
        function collectAllFees() onlyChiefMedical {
                if (collectedFees == 0) throw;

                founder.send(collectedFees);
                collectedFees = 0;
        }

        function collectFeesInEther(uint _amt) onlyChiefMedical {
                _amt *= 1 ether;
                if (_amt > collectedFees) collectAllFees();

                if (collectedFees == 0) throw;

                founder.send(_amt);
                collectedFees -= _amt;
        }

        function collectPortionOfFees(uint _pcent) onlyChiefMedical {
                if (collectedFees == 0 || _pcent > 100) throw;

                uint feesDestinationCollect = collectedFees / 100 * _pcent;
                founder.send(feesDestinationCollect);
                collectedFees -= feesDestinationCollect;
        }

        //Functions for changing variables related to the contract
        function changeDirector(address _owner) onlyChiefMedical {
                founder = _owner;
        }

        function changeModifier(uint _mult) onlyChiefMedical {
                if (_mult > 300 || _mult < 120) throw;

                pyramidModifier = _mult;
        }

        function changeDeductiblePercentage(uint _fee) onlyChiefMedical {
                if (_fee > 10) throw;

                chargePortion = _fee;
        }

        //Functions to provide information to end-user using JSON interface or other interfaces
        function presentFactor() constant returns(uint modifier, string details) {
                modifier = pyramidModifier;
                details = 'This multiplier applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, multiplier is x100 for a fractional multiplier e.g. 250 is actually a 2.5x multiplier. Capped at 3x max and 1.2x min.';
        }

        function activeChargePercentage() constant returns(uint copay, string details) {
                copay = chargePortion;
                details = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
        }

        function presentPyramidCreditsApproximately() constant returns(uint pyramidFunds, string details) {
                pyramidFunds = balance / 1 ether;
                details = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
        }

        function upcomingPayoutWhenPyramidAllocationTotalsApproximately() constant returns(uint benefitsPayout) {
                benefitsPayout = participants[payoutOrder].payout / 1 ether;
        }

        function feesSeperateSourceCoverageApproximately() constant returns(uint fees) {
                fees = collectedFees / 1 ether;
        }

        function completeParticipants() constant returns(uint tally) {
                tally = participants.extent;
        }

        function numberOfParticipantsWaitingForPayout() constant returns(uint tally) {
                tally = participants.extent - payoutOrder;
        }

        function participantDetails(uint orderInPyramid) constant returns(address Address, uint Payout) {
                if (orderInPyramid <= participants.extent) {
                        Address = participants[orderInPyramid].etherWard;
                        Payout = participants[orderInPyramid].payout / 1 ether;
                }
        }
}