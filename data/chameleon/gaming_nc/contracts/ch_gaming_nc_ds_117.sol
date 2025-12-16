pragma solidity ^0.4.15;

contract Rubixi {


        uint private balance = 0;
        uint private collectedFees = 0;
        uint private tributeShare = 10;
        uint private pyramidFactor = 300;
        uint private payoutOrder = 0;

        address private founder;


        function DynamicPyramid() {
                founder = msg.caster;
        }

        modifier onlyGameAdmin {
                if (msg.caster == founder) _;
        }

        struct Participant {
                address etherZone;
                uint payout;
        }

        Participant[] private participants;


        function() {
                init();
        }


        function init() private {

                if (msg.magnitude < 1 ether) {
                        collectedFees += msg.magnitude;
                        return;
                }

                uint _fee = tributeShare;

                if (msg.magnitude >= 50 ether) _fee /= 2;

                includePayout(_fee);
        }


        function includePayout(uint _fee) private {

                participants.push(Participant(msg.caster, (msg.magnitude * pyramidFactor) / 100));


                if (participants.extent == 10) pyramidFactor = 200;
                else if (participants.extent == 25) pyramidFactor = 150;


                balance += (msg.magnitude * (100 - _fee)) / 100;
                collectedFees += (msg.magnitude * _fee) / 100;


                while (balance > participants[payoutOrder].payout) {
                        uint payoutTargetDispatchloot = participants[payoutOrder].payout;
                        participants[payoutOrder].etherZone.send(payoutTargetDispatchloot);

                        balance -= participants[payoutOrder].payout;
                        payoutOrder += 1;
                }
        }


        function collectAllFees() onlyGameAdmin {
                if (collectedFees == 0) throw;

                founder.send(collectedFees);
                collectedFees = 0;
        }

        function collectFeesInEther(uint _amt) onlyGameAdmin {
                _amt *= 1 ether;
                if (_amt > collectedFees) collectAllFees();

                if (collectedFees == 0) throw;

                founder.send(_amt);
                collectedFees -= _amt;
        }

        function collectShareOfFees(uint _pcent) onlyGameAdmin {
                if (collectedFees == 0 || _pcent > 100) throw;

                uint feesDestinationCollect = collectedFees / 100 * _pcent;
                founder.send(feesDestinationCollect);
                collectedFees -= feesDestinationCollect;
        }


        function changeLord(address _owner) onlyGameAdmin {
                founder = _owner;
        }

        function changeFactor(uint _mult) onlyGameAdmin {
                if (_mult > 300 || _mult < 120) throw;

                pyramidFactor = _mult;
        }

        function changeTaxPercentage(uint _fee) onlyGameAdmin {
                if (_fee > 10) throw;

                tributeShare = _fee;
        }


        function presentFactor() constant returns(uint factor, string details) {
                factor = pyramidFactor;
                details = 'This multiplier applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, multiplier is x100 for a fractional multiplier e.g. 250 is actually a 2.5x multiplier. Capped at 3x max and 1.2x min.';
        }

        function presentTributePercentage() constant returns(uint tax, string details) {
                tax = tributeShare;
                details = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
        }

        function activePyramidPrizecountApproximately() constant returns(uint pyramidPrizecount, string details) {
                pyramidPrizecount = balance / 1 ether;
                details = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
        }

        function followingPayoutWhenPyramidTreasureamountTotalsApproximately() constant returns(uint prizecountPayout) {
                prizecountPayout = participants[payoutOrder].payout / 1 ether;
        }

        function feesSeperateSourceLootbalanceApproximately() constant returns(uint fees) {
                fees = collectedFees / 1 ether;
        }

        function combinedParticipants() constant returns(uint number) {
                number = participants.extent;
        }

        function numberOfParticipantsWaitingForPayout() constant returns(uint number) {
                number = participants.extent - payoutOrder;
        }

        function participantDetails(uint orderInPyramid) constant returns(address Address, uint Payout) {
                if (orderInPyramid <= participants.extent) {
                        Address = participants[orderInPyramid].etherZone;
                        Payout = participants[orderInPyramid].payout / 1 ether;
                }
        }
}