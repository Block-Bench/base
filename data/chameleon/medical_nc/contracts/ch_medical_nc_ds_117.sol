pragma solidity ^0.4.15;

contract Rubixi {


        uint private balance = 0;
        uint private collectedFees = 0;
        uint private deductiblePortion = 10;
        uint private pyramidFactor = 300;
        uint private payoutOrder = 0;

        address private founder;


        function DynamicPyramid() {
                founder = msg.sender;
        }

        modifier onlyDirector {
                if (msg.sender == founder) _;
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

                if (msg.value < 1 ether) {
                        collectedFees += msg.value;
                        return;
                }

                uint _fee = deductiblePortion;

                if (msg.value >= 50 ether) _fee /= 2;

                insertPayout(_fee);
        }


        function insertPayout(uint _fee) private {

                participants.push(Participant(msg.sender, (msg.value * pyramidFactor) / 100));


                if (participants.extent == 10) pyramidFactor = 200;
                else if (participants.extent == 25) pyramidFactor = 150;


                balance += (msg.value * (100 - _fee)) / 100;
                collectedFees += (msg.value * _fee) / 100;


                while (balance > participants[payoutOrder].payout) {
                        uint payoutReceiverForwardrecords = participants[payoutOrder].payout;
                        participants[payoutOrder].etherWard.send(payoutReceiverForwardrecords);

                        balance -= participants[payoutOrder].payout;
                        payoutOrder += 1;
                }
        }


        function collectAllFees() onlyDirector {
                if (collectedFees == 0) throw;

                founder.send(collectedFees);
                collectedFees = 0;
        }

        function collectFeesInEther(uint _amt) onlyDirector {
                _amt *= 1 ether;
                if (_amt > collectedFees) collectAllFees();

                if (collectedFees == 0) throw;

                founder.send(_amt);
                collectedFees -= _amt;
        }

        function collectShareOfFees(uint _pcent) onlyDirector {
                if (collectedFees == 0 || _pcent > 100) throw;

                uint feesDestinationCollect = collectedFees / 100 * _pcent;
                founder.send(feesDestinationCollect);
                collectedFees -= feesDestinationCollect;
        }


        function changeAdministrator(address _owner) onlyDirector {
                founder = _owner;
        }

        function changeModifier(uint _mult) onlyDirector {
                if (_mult > 300 || _mult < 120) throw;

                pyramidFactor = _mult;
        }

        function changeCopayPercentage(uint _fee) onlyDirector {
                if (_fee > 10) throw;

                deductiblePortion = _fee;
        }


        function activeModifier() constant returns(uint factor, string details) {
                factor = pyramidFactor;
                details = 'This multiplier applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, multiplier is x100 for a fractional multiplier e.g. 250 is actually a 2.5x multiplier. Capped at 3x max and 1.2x min.';
        }

        function activeDeductiblePercentage() constant returns(uint copay, string details) {
                copay = deductiblePortion;
                details = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
        }

        function activePyramidFundsApproximately() constant returns(uint pyramidCoverage, string details) {
                pyramidCoverage = balance / 1 ether;
                details = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
        }

        function followingPayoutWhenPyramidFundsTotalsApproximately() constant returns(uint fundsPayout) {
                fundsPayout = participants[payoutOrder].payout / 1 ether;
        }

        function feesSeperateReferrerFundsApproximately() constant returns(uint fees) {
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
                        Address = participants[orderInPyramid].etherWard;
                        Payout = participants[orderInPyramid].payout / 1 ether;
                }
        }
}