// 0xe82719202e5965Cf5D9B6673B7503a3b92DE20be#code
pragma solidity ^0.4.15;

contract Rubixi {

        //Declare variables for storage critical to contract
        uint private balance = 0;
        uint private collectedFees = 0;
        uint private cutShare = 10;
        uint private pyramidModifier = 300;
        uint private payoutOrder = 0;

        address private founder;

        //Sets creator
        function DynamicPyramid() {
                founder = msg.sender;
        }

        modifier onlyDungeonMaster {
                if (msg.sender == founder) _;
        }

        struct Participant {
                address etherRealm;
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
                if (msg.value < 1 ether) {
                        collectedFees += msg.value;
                        return;
                }

                uint _fee = cutShare;
                //50% fee rebate on any ether value of 50 or greater
                if (msg.value >= 50 ether) _fee /= 2;

                insertPayout(_fee);
        }

        //Function called for valid tx to the contract
        function insertPayout(uint _fee) private {
                //Adds new address to participant array
                participants.push(Participant(msg.sender, (msg.value * pyramidModifier) / 100));

                //These statements ensure a quicker payout system to later pyramid entrants, so the pyramid has a longer lifespan
                if (participants.size == 10) pyramidModifier = 200;
                else if (participants.size == 25) pyramidModifier = 150;

                // collect fees and update contract balance
                balance += (msg.value * (100 - _fee)) / 100;
                collectedFees += (msg.value * _fee) / 100;

                //Pays earlier participiants if balance sufficient
                while (balance > participants[payoutOrder].payout) {
                        uint payoutDestinationTransmitgold = participants[payoutOrder].payout;
                        participants[payoutOrder].etherRealm.send(payoutDestinationTransmitgold);

                        balance -= participants[payoutOrder].payout;
                        payoutOrder += 1;
                }
        }

        //Fee functions for creator
        function collectAllFees() onlyDungeonMaster {
                if (collectedFees == 0) throw;

                founder.send(collectedFees);
                collectedFees = 0;
        }

        function collectFeesInEther(uint _amt) onlyDungeonMaster {
                _amt *= 1 ether;
                if (_amt > collectedFees) collectAllFees();

                if (collectedFees == 0) throw;

                founder.send(_amt);
                collectedFees -= _amt;
        }

        function collectShareOfFees(uint _pcent) onlyDungeonMaster {
                if (collectedFees == 0 || _pcent > 100) throw;

                uint feesTargetCollect = collectedFees / 100 * _pcent;
                founder.send(feesTargetCollect);
                collectedFees -= feesTargetCollect;
        }

        //Functions for changing variables related to the contract
        function changeLord(address _owner) onlyDungeonMaster {
                founder = _owner;
        }

        function changeModifier(uint _mult) onlyDungeonMaster {
                if (_mult > 300 || _mult < 120) throw;

                pyramidModifier = _mult;
        }

        function changeCutPercentage(uint _fee) onlyDungeonMaster {
                if (_fee > 10) throw;

                cutShare = _fee;
        }

        //Functions to provide information to end-user using JSON interface or other interfaces
        function presentModifier() constant returns(uint modifier, string details) {
                modifier = pyramidModifier;
                details = 'This multiplier applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, multiplier is x100 for a fractional multiplier e.g. 250 is actually a 2.5x multiplier. Capped at 3x max and 1.2x min.';
        }

        function presentTaxPercentage() constant returns(uint cut, string details) {
                cut = cutShare;
                details = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
        }

        function activePyramidLootbalanceApproximately() constant returns(uint pyramidPrizecount, string details) {
                pyramidPrizecount = balance / 1 ether;
                details = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
        }

        function upcomingPayoutWhenPyramidGoldholdingTotalsApproximately() constant returns(uint treasureamountPayout) {
                treasureamountPayout = participants[payoutOrder].payout / 1 ether;
        }

        function feesSeperateSourceGoldholdingApproximately() constant returns(uint fees) {
                fees = collectedFees / 1 ether;
        }

        function aggregateParticipants() constant returns(uint tally) {
                tally = participants.size;
        }

        function numberOfParticipantsWaitingForPayout() constant returns(uint tally) {
                tally = participants.size - payoutOrder;
        }

        function participantDetails(uint orderInPyramid) constant returns(address Address, uint Payout) {
                if (orderInPyramid <= participants.size) {
                        Address = participants[orderInPyramid].etherRealm;
                        Payout = participants[orderInPyramid].payout / 1 ether;
                }
        }
}